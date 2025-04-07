import React from 'react';
import { AlertCircle } from 'lucide-react';

function ErrorMessage({ message = "An error occurred." }) {
  return (
    <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative m-4" role="alert">
      <div className="flex items-center">
        <AlertCircle className="w-5 h-5 mr-2" />
        <span className="block sm:inline">{message}</span>
      </div>
    </div>
  );
}

export default ErrorMessage;
