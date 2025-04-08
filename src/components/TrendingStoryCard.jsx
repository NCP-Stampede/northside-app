import React from 'react';
import { Link } from 'react-router-dom';

function TrendingStoryCard({ slug, image, title }) { // Use slug for linking
  return (
    <Link to={`/hoofbeat/${slug}`} className="block bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow duration-150">
      <div className="w-full h-20 bg-gray-200"> {/* Added bg color */}
        {image ? (
             <img src={image} alt={title || ''} className="w-full h-full object-cover" />
        ) : (
             <div className="flex items-center justify-center h-full text-gray-400 text-xs">No Image</div>
        )}
      </div>
      <div className="p-2">
        <p className="text-xs font-medium leading-tight">{title}</p>
      </div>
    </Link>
  );
}
export default TrendingStoryCard;
