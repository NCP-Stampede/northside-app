import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

function SportListItem({ id, name, season }) {
    return (
         <Link // Wrap with Link
             to={`/athletics/sports/${id}`} // Use the sport ID in the path
             className="bg-white rounded-lg shadow p-4 flex items-center justify-between mb-2 cursor-pointer hover:bg-gray-50 transition duration-150"
         >
             <span className="font-medium">{name}</span>
             <ChevronRight size={16} className="text-gray-400" />
         </Link>
    );
}
export default SportListItem;
