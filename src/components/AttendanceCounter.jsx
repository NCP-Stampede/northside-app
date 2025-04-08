import React from 'react';

function AttendanceCounter({ label, count, color }) {
  return (
    <div className="flex flex-col items-center text-center">
      <div className={`w-12 h-12 ${color} rounded-full flex items-center justify-center text-white font-bold text-lg mb-1`}>
        {count}
      </div>
      <span className="text-sm text-gray-600">{label}</span>
    </div>
  );
}

export default AttendanceCounter;
