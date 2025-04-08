import React from 'react';
import { Link } from 'react-router-dom';
import { AlertTriangle } from 'lucide-react'; // Icon

function NotFoundScreen() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[calc(100vh-4rem)] text-center px-4">
        <AlertTriangle size={64} className="text-yellow-500 mb-4"/>
      <h1 className="text-6xl font-bold text-gray-800 mb-4">404</h1>
      <h2 className="text-2xl font-semibold text-gray-600 mb-6">Page Not Found</h2>
      <p className="text-gray-500 mb-8 max-w-md">
        Sorry, the page you are looking for does not exist, may have been moved, or you do not have permission to view it.
      </p>
      <Link
        to="/"
        className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition duration-150"
      >
        Go to Homepage
      </Link>
    </div>
  );
}

export default NotFoundScreen;
