import React from 'react';
// Removed Link wrapper here, it will be added in GradesScreen for better control

function GradeCard({ course, teacher, grade, letterGrade, isFailing = false }) {
  return (
    // Basic structure, Link wrapper will be applied in the parent screen
    <div className="bg-white rounded-xl shadow-sm p-4 flex items-center justify-between cursor-pointer hover:bg-gray-50 transition duration-150">
      <div>
        <h3 className="font-medium">{course}</h3>
        <p className="text-xs text-gray-500">{teacher}</p>
      </div>
      <div className={`w-12 h-8 rounded-md flex items-center justify-center font-bold text-white text-sm ${isFailing ? 'bg-red-500' : 'bg-green-500'}`}>
        {letterGrade}
      </div>
    </div>
  );
}

export default GradeCard;
