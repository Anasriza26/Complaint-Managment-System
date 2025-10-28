var fs = require('fs');

function getAllEquipment(req, res, con) {
  var sql = "SELECT DISTINCT(equipment) FROM master_data";
  con.query(sql, function (err, result) {
    if (err) {
      console.log(err);
      res.end("false");
      return;
    }
    res.end(JSON.stringify(result));
  });
}

function getAllHistory(req, res, con) {
  var values = req.query;
  var sInfoRadio = values.sInfoRadio;
  var sInfoValue = "";
  var handyman_id = "";

  try { sInfoValue = values.sInfoValue.trim(); } catch { sInfoValue = "" }
  try { handyman_id = values.handyman_id.trim(); } catch { handyman_id = "" }

  var subject = values.subject.trim();
  var catagory = values.catagory.trim();
  var time_slot = values.time_slot.trim();
  var type = values.type.trim();
  var status = values.status.trim();
  var rating = values.rating.trim();

  var sql = "SELECT * FROM complaint_info c, handyman_info h, student_info s WHERE c.handyman_id=h.handyman_id AND c.student_id=s.student_id ";

  if (handyman_id != "") sql += "AND c.handyman_id=" + handyman_id + " ";
  if (sInfoValue != "") {
    if (sInfoRadio == "name") sql += "AND s.name='" + sInfoValue + "' ";
    if (sInfoRadio == "roll") sql += "AND roll_no='" + sInfoValue + "' ";
    if (sInfoRadio == "room") {
      var parts = sInfoValue.split(" ");
      sql += "AND room_no=" + parts[1] + " AND gender='" + parts[0] + "' ";
    }
  }
  if (subject != "Any") sql += "AND subject='" + subject + "' ";
  if (catagory != "Any") sql += "AND c.catagory='" + catagory + "' ";
  if (time_slot != "Any") sql += "AND time_slot='" + time_slot + "' ";
  if (type != "Any") sql += "AND type='" + type + "' ";

  if (status != "Any") {
    if (status == "Lodged") status = "(0)";
    if (status == "Unsolved") status = "(0,1)";
    if (status == "Progress") status = "(1)";
    if (status == "Solved") status = "(2,3)";
    if (status == "Closed") status = "(3)";
    sql += "AND status IN " + status + " ";
  }

  if (rating != "Any") {
    if (rating == "Poor") rating = "(1,2)";
    if (rating == "Average") rating = "(3)";
    if (rating == "Good") rating = "(4,5)";
    sql += "AND rating IN " + rating + " ";
  }

  con.query({ sql: sql, nestTables: true }, function (err, result) {
    if (err) {
      console.log(err);
      res.end("false");
      return;
    }
    res.end(JSON.stringify(result));
  });
}

// ------------------- ASSIGN WORK CORE LOGIC ------------------- //

function assignWorkHelper(Data, slot, result, status, res, con) {
  let id = null;
  let min = 10;
  let sequence = -1;

  for (let i in Data) {
    if (min > Data[i][slot]) {
      min = Data[i][slot];
      id = Data[i]['handyman_id'];
      sequence = i;
    }
  }

  if (min >= 5) return -1;

  let sql = "";
  if (status == 0)
    sql = `UPDATE complaint_info SET handyman_id=${id}, status=1, assignDate=NOW() WHERE complaint_id=${result.complaint_id}`;
  else
    sql = `UPDATE complaint_info SET handyman_id=${id}, status=1 WHERE complaint_id=${result.complaint_id}`;

  con.query(sql, function (err) {
    if (err) {
      console.log(err);
      res.end("false");
    }
  });

  return sequence;
}

// ✅ DYNAMIC VERSION OF ASSIGN WORK — Handles all categories
function assignWorkDynamic(handymanGroups, con, res) {
  const sql = "SELECT complaint_id, time_slot, catagory, status FROM complaint_info WHERE status < 2";
  con.query(sql, function (err, complaints) {
    if (err) {
      console.log(err);
      res.end("false");
      return;
    }

    for (let i in complaints) {
      const cat = complaints[i].catagory;
      let slot = "slot1";

      if (complaints[i].time_slot === "10:00-12:00") slot = "slot1";
      else if (complaints[i].time_slot === "13:00-15:00") slot = "slot2";
      else if (complaints[i].time_slot === "16:00-18:00") slot = "slot3";

      if (handymanGroups[cat]) {
        const seq = assignWorkHelper(handymanGroups[cat], slot, complaints[i], complaints[i].status, res, con);
        if (seq >= 0) {
          handymanGroups[cat][seq][slot]++;
          handymanGroups[cat][seq]['issued']++;
        }
      } else {
        console.log(`⚠️ No handyman found for category: ${cat}`);
      }
    }

    // Update all handyman_info
    Object.keys(handymanGroups).forEach(cat => {
      handymanGroups[cat].forEach(h => {
        const updateSQL = `
          UPDATE handyman_info 
          SET slot1=${h.slot1}, slot2=${h.slot2}, slot3=${h.slot3}, issued=${h.issued}
          WHERE handyman_id=${h.handyman_id}`;
        con.query(updateSQL, err => { if (err) console.log(err); });
      });
    });

    res.end("true");
  });
}

// ------------------- ADMIN FUNCTIONS ------------------- //

function changeAdminPassword(req, res, con) {
  const admin_id = req.query.admin_id;
  const old_pass = req.query.old_Pass;
  const new_pass = req.query.new_Pass;

  const sql = "UPDATE admin_info SET password=? WHERE admin_id=? AND password=?";
  con.query(sql, [new_pass, admin_id, old_pass], function (err, result) {
    if (err) {
      console.log(err);
      res.end("false");
    } else if (result.affectedRows == 1) res.end("true");
    else res.end("old");
  });
}

function changeAdminPhone(req, res, con) {
  const admin_id = req.query.admin_id;
  const phone = req.query.new_phone;

  const sql = "UPDATE admin_info SET phone_no=? WHERE admin_id=?";
  con.query(sql, [phone, admin_id], function (err, result) {
    if (err) {
      console.log(err);
      res.end("false");
    } else if (result.affectedRows == 1) res.end("true");
  });
}

function adminComplaintAnalysis(req, res, con) {
  const sql = "SELECT COUNT(*) AS total FROM complaint_info UNION SELECT COUNT(*) AS solved FROM complaint_info WHERE status>=2";
  con.query(sql, function (err, result) {
    if (err) {
      console.log(err);
      res.end("false");
      return;
    }
    res.end(JSON.stringify(result));
  });
}

function adminGetIndexPageData(req, res) {
  fs.readFile('Help_Details', 'utf8', function (err, data) {
    let Help_Details = '{' + data + '}';
    res.end(Help_Details);
  });
}

// ------------------- MAIN EXPORT MODULE ------------------- //

module.exports = {
  // ✅ DYNAMIC ASSIGN FUNCTION
  assign: function (req, res, con) {
    const ids = req; // expecting something like (1,2,3)
    const handymanGroups = {};

    // reset slots for all handymen
    const resetSQL = "UPDATE handyman_info SET slot1=0, slot2=0, slot3=0, today=0";
    con.query(resetSQL, function (err) {
      if (err) {
        console.log(err);
        res.end("false");
        return;
      }

      // get all categories dynamically
      const catSQL = "SELECT DISTINCT Catagory FROM handyman_info";
      con.query(catSQL, function (err, categories) {
        if (err) {
          console.log(err);
          res.end("false");
          return;
        }

        let pending = categories.length;

        categories.forEach(cat => {
          const query = `SELECT * FROM handyman_info WHERE Catagory='${cat.Catagory}' AND handyman_id IN ${ids}`;
          con.query(query, function (err, result) {
            if (err) {
              console.log(err);
              res.end("false");
              return;
            }

            handymanGroups[cat.Catagory] = result;
            pending--;

            if (pending === 0) {
              // all categories loaded
              assignWorkDynamic(handymanGroups, con, res);
            }
          });
        });
      });
    });
  },

  getHandyManInfo: function (req, res, con) {
    var sql = "SELECT * FROM handyman_info";
    con.query(sql, function (err, result) {
      if (err) {
        console.log(err);
        res.end("false");
        return;
      }
      res.end(JSON.stringify(result));
    });
  },

  getHandyManRating: function (req, res, con) {
    var handyman_id = req.query.handyman_id;
    var sql = "SELECT ROUND(AVG(rating),2) AS rating FROM complaint_info WHERE handyman_id=" + handyman_id + " AND rating IS NOT NULL AND rating<>0";
    con.query(sql, function (err, result) {
      if (err) {
        res.end("false");
        return;
      }
      res.end(JSON.stringify(result));
    });
  },

  getAllHistory: function (req, res, con) {
    getAllHistory(req, res, con);
  },

  getAllEquipment: function (req, res, con) {
    getAllEquipment(req, res, con);
  },

  changeAdminPassword: function (req, res, con) {
    changeAdminPassword(req, res, con);
  },

  changeAdminPhone: function (req, res, con) {
    changeAdminPhone(req, res, con);
  },

  adminComplaintAnalysis: function (req, res, con) {
    adminComplaintAnalysis(req, res, con);
  },

  adminGetIndexPageData: function (req, res) {
    adminGetIndexPageData(req, res);
  }
};
