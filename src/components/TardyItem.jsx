import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

function TardyItem({ id, course, teacher, date }) { // Receive id
  return (
     <Link
         to={`/attendance/tardies/${id}`} // Link to Tardy Detail Screen
         className="block py-3 border-b border-gray-100 last:border-0 hover:bg-gray-50 -mx-4 px-4 transition duration-150" // Adjust padding/margin for hover effect
     >
      <div className="flex justify-between items-center">
         <div>
            <h3 className="font-medium text-sm">{course}</h3>
            <div className="flex items-center text-xs text-gray-500 mt-1">
                <span>{teacher}</span>
                <span className="mx-2">•</span>
                <span>{date}</span>
            </div>
         </div>
          <ChevronRight size={16} className="text-gray-400 flex-shrink-0" />
       </div>
    </Link>
  );
}
export default TardyItem;
