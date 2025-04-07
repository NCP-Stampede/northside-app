import React from 'react';
import { Link } from 'react-router-dom'; // Import Link

// Use 'to' prop for navigation destination instead of onClick
function QuickLinkCard({ icon, title, color, to }) {
  return (
    <Link
      to={to} // Use the 'to' prop for the link destination
      className="bg-white rounded-xl shadow-sm p-4 flex items-center cursor-pointer hover:shadow-md transition-shadow duration-150"
    >
      <div className={`w-10 h-10 ${color} rounded-full flex items-center justify-center text-white mr-3 flex-shrink-0`}>
        {icon}
      </div>
      <span className="font-medium text-sm">{title}</span>
    </Link>
  );
}

export default QuickLinkCard;
