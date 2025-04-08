import React, { useState, useEffect } from 'react';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import AttendanceCounter from '../components/AttendanceCounter';
import TardyItem from '../components/TardyItem';
import { fetchAttendance } from '../services/api';

function AttendanceScreen() {
    const [attendanceData, setAttendanceData] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true); setError(null);
            try {
                const data = await fetchAttendance();
                setAttendanceData(data);
            } catch (err) { setError("Failed to load attendance data."); console.error(err); }
            finally { setIsLoading(false); }
        };
        loadData();
    }, []);

  return (
    <div className="p-4">
      <header className="mb-6">
        <h1 className="text-2xl font-bold">Attendance</h1>
         {/* Add filters if needed (e.g., by term, year) */}
      </header>

        {isLoading && <LoadingSpinner />}
        {error && <ErrorMessage message={error} />}

        {!isLoading && !error && attendanceData && (
            <>
                {/* Summary Counters */}
                {attendanceData.summary && (
                    <div className="flex space-x-4 justify-around mb-8">
                        <AttendanceCounter label="Present" count={attendanceData.summary.present || 0} color="bg-green-500" />
                        <AttendanceCounter label="Tardy" count={attendanceData.summary.tardy || 0} color="bg-yellow-500" />
                        <AttendanceCounter label="Absent" count={attendanceData.summary.absent || 0} color="bg-red-500" />
                    </div>
                )}

                {/* Tardies List */}
                 {attendanceData.tardies?.length > 0 && (
                     <>
                        <h2 className="text-lg font-semibold mb-3">Tardies</h2>
                        <div className="bg-white rounded-xl shadow-sm px-4 overflow-hidden"> {/* Adjust padding for Link hover */}
                           {attendanceData.tardies.map(tardy => (
                               <TardyItem key={tardy.id} {...tardy} id={tardy.id} />
                           ))}
                        </div>
                    </>
                 )}

                {/* Absences List (Add similarly if data is available) */}
                 {/* {attendanceData.absences?.length > 0 && ( ... )} */}

                 {attendanceData.tardies?.length === 0 /* && attendanceData.absences?.length === 0 */ && (
                     <p className="text-center text-gray-500 mt-8">No recent tardies or absences recorded.</p>
                 )}

            </>
        )}

        {!isLoading && !error && !attendanceData && (
            <p className="text-center text-gray-500 mt-8">Could not load attendance data.</p>
        )}

    </div>
  );
}

export default AttendanceScreen;
