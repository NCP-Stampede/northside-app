import React from 'react';
import { Link } from 'react-router-dom'; // Import Link if card should be clickable

// Example: Make the card link somewhere (optional, adjust 'to' prop)
function PromotionCard({ title, date, image, to = "#" }) {
  const content = (
    <>
        {image ? (
             <img src={image} alt={title} className="w-full h-32 object-cover" />
        ) : (
            <div className="w-full h-32 bg-gray-200 flex items-center justify-center text-gray-400">No Image</div>
        )}
        <div className="p-3">
            <h3 className="text-lg font-bold">{title}</h3>
            <p className="text-sm text-gray-500">{date}</p>
        </div>
    </>
  );

  if (to && to !== "#") {
    return (
        <Link to={to} className="block relative hover:opacity-90 transition-opacity duration-150">
            {content}
        </Link>
    );
  }

  return <div className="relative">{content}</div>;
}

export default PromotionCard;
