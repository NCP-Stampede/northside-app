import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import GradeCard from '../components/GradeCard';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { fetchGrades } from '../services/api';

function GradesScreen() {
  const [grades, setGrades] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [filter, setFilter] = useState('currentYear'); // Example filter state

  useEffect(() => {
    const loadData = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const data = await fetchGrades({ filter });
        setGrades(data);
      } catch (err) {
        console.error("Failed to fetch grades:", err);
        setError(err.message || 'Could not load grades. Please try again.');
      } finally {
        setIsLoading(false);
      }
    };

    loadData();
  }, [filter]); // Re-fetch when filter changes

  const handleFilterChange = (newFilter) => {
    setFilter(newFilter);
  };

  return (
    <div className="p-4">
      <header className="mb-4">
        <h1 className="text-2xl font-bold">Grades</h1>
        {/* Filter controls */}
        <div className="flex space-x-4 text-sm mt-2">
          <button
            onClick={() => handleFilterChange('currentYear')}
            className={`pb-1 ${filter === 'currentYear' ? 'text-blue-500 font-semibold border-b-2 border-blue-500' : 'text-gray-500 hover:text-gray-700'}`}
          >
            Current Year
          </button>
          <button
            onClick={() => handleFilterChange('currentTerm')}
            className={`pb-1 ${filter === 'currentTerm' ? 'text-blue-500 font-semibold border-b-2 border-blue-500' : 'text-gray-500 hover:text-gray-700'}`}
          >
            Current Term
          </button>
           {/* Add more filters as needed */}
        </div>
      </header>

      {isLoading && <LoadingSpinner />}
      {error && <ErrorMessage message={error} />}

      {!isLoading && !error && (
        <div className="space-y-3">
          {grades.length > 0 ? (
            grades.map((grade) => (
              // Wrap GradeCard with Link here
              <Link key={grade.id} to={`/grades/${grade.id}`} aria-label={`View details for ${grade.course}`}>
                  <GradeCard {...grade} />
              </Link>
            ))
          ) : (
            <p className="text-center text-gray-500 mt-8">No grades found for the selected filter.</p>
          )}
        </div>
      )}
    </div>
  );
}

export default GradesScreen;
