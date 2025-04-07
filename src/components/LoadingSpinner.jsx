import React from 'react';

function LoadingSpinner() {
  // Basic spinner, replace with a more visually appealing one if desired
  return (
    <div className="flex justify-center items-center p-10">
      <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
    </div>
  );
}

export default LoadingSpinner;
