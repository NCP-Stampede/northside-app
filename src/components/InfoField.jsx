import React from 'react';

function InfoField({ label, value }) {
  return (
    <div className="bg-white rounded-xl shadow-sm p-4">
      <label className="block text-xs text-gray-500 mb-1">{label}</label>
      <div className="font-medium text-sm">{value || '-'}</div> {/* Added fallback */}
    </div>
  );
}

export default InfoField;
