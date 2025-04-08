import React from 'react';
import { Link } from 'react-router-dom';

function FeaturedStoryCard({ slug, title, author, image, tag }) { // Use slug for linking
  return (
    <Link to={`/hoofbeat/${slug}`} className="block bg-white rounded-xl shadow-sm overflow-hidden hover:shadow-md transition-shadow duration-150 mb-6">
      <div className="relative h-40 bg-gray-200"> {/* Added bg color */}
          {image ? (
            <img src={image} alt={title || ''} className="w-full h-full object-cover" />
          ) : (
            <div className="flex items-center justify-center h-full text-gray-400">No Image</div>
          )}
      </div>
      <div className="p-4">
         {tag && <div className="inline-block px-2 py-1 bg-red-500 text-white text-xs font-medium rounded mb-2">{tag}</div>}
         <h2 className="font-bold mb-1 text-lg">{title}</h2>
         <p className="text-sm text-gray-500">Last Updated By {author}</p>
      </div>
    </Link>
  );
}
export default FeaturedStoryCard;
