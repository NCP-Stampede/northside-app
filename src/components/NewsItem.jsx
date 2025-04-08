import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight, Image as ImageIcon } from 'lucide-react'; // Added placeholder icon

function NewsItem({ slug, title }) { // Use slug for linking
  return (
    <Link to={`/hoofbeat/${slug}`} className="block bg-gray-100 hover:bg-gray-200 rounded-lg p-3 flex items-center transition duration-150">
      {/* Placeholder icon */}
      <div className="w-8 h-8 bg-gray-300 rounded-full mr-3 flex-shrink-0 flex items-center justify-center">
          <ImageIcon size={16} className="text-gray-500" />
      </div>
      <p className="text-sm font-medium flex-grow mr-2">{title}</p>
       {/* Optional: Add chevron */}
       <ChevronRight size={16} className="text-gray-400 flex-shrink-0" />
    </Link>
  );
}
export default NewsItem;
