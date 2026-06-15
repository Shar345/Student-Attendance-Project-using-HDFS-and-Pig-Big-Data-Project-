from flask import Flask, render_template, request, redirect, url_for
import csv
import os
import subprocess

app = Flask(__name__)

students = []

# Load students from CSV
with open("students.csv") as f:
    reader = csv.reader(f)
    
    next(reader)  # Skip header row

    for row in reader:
        students.append({
            "rollno": row[0],
            "name": row[1]
        })


@app.route("/")
def index():
    return render_template("index.html", students=students)


@app.route("/submit", methods=["POST"])
def submit():

    date = request.form["date"]
    subject = request.form["subject"]

    with open("attendance.csv", "a", newline="") as f:

        writer = csv.writer(f)

        for student in students:

            roll = student["rollno"]
            name = student["name"]

            if roll in request.form:
                status = "Present"
            else:
                status = "Absent"

            writer.writerow([date, subject, roll, name, status])

    # Automatically update Hadoop HDFS file
    try:
        project_path = "C:\\Users\\admin\\Desktop\\attendance_project"
        subprocess.run(
            [
                "C:\\hadoop-2.9.2_College\\hadoop-2.9.2\\bin\\hdfs",
                "dfs",
                "-rm",
                "-f",
                "/attendance/attendance.csv"
            ],
            cwd=project_path,
            stderr=subprocess.DEVNULL
        )
    
    except Exception as e:
        print("Error uploading to HDFS:", e)

    

    # Automatically update Hadoop HDFS file
    try:
        subprocess.run(
            "C:\\hadoop-2.9.2_College\\hadoop-2.9.2\\bin\\hdfs dfs -rm -f /attendance/attendance.csv",
            shell=True
        )
        
        subprocess.run(
            "C:\\hadoop-2.9.2_College\\hadoop-2.9.2\\bin\\hdfs dfs -D dfs.blocksize=536870912 -put attendance.csv /attendance/",
            shell=True
        )
        print("Attendance updated in HDFS successfully")

    except Exception as e:
        print("Error uploading to HDFS:", e)

    return redirect(url_for("index"))


if __name__ == "__main__":
    app.run(debug=True)