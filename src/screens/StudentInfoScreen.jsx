import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchStudentInfo } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import InfoField from '../components/InfoField'; // Reusable component
import InfoSection from '../components/InfoSection'; // Reusable component
import InfoPair from '../components/InfoPair'; // Reusable component
import { ChevronLeft } from 'lucide-react';

function StudentInfoScreen() {
    const navigate = useNavigate();
    const [info, setInfo] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

     useEffect(() => {
        const loadData = async () => {
            setIsLoading(true); setError(null);
            try {
                const data = await fetchStudentInfo();
                setInfo(data);
            } catch (err) { setError("Failed to load student information."); console.error(err); }
            finally { setIsLoading(false); }
        };
        loadData();
    }, []);


  return (
    <div className="p-4">
      <header className="flex items-center mb-6 -ml-1">
         <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" aria-label="Go back">
            <ChevronLeft size={24} className="text-blue-600" />
         </button>
        <h1 className="text-xl font-bold ml-2">Student Information</h1>
      </header>

        {isLoading && <LoadingSpinner />}
        {error && <ErrorMessage message={error} />}

        {!isLoading && !error && info && (
            // Use InfoSection/InfoPair for consistency if desired, or InfoField
            <div className="space-y-4">
                <InfoField label="First Name" value={info.firstName} />
                <InfoField label="Last Name" value={info.lastName} />
                <InfoField label="Middle Initial" value={info.middleInitial} />
                <InfoField label="Student ID" value={info.studentId} />
                <InfoField label="Grade" value={info.grade} />
                <InfoField label="Date of Birth" value={info.dob} />

                 {/* Example using InfoSection/InfoPair for parent info (if fetched) */}
                 {/* <InfoSection title="Parent/Guardian">
                     <InfoPair label="Name" value={info.parentName} />
                     <InfoPair label="Email" value={info.parentEmail} />
                 </InfoSection> */}
            </div>
        )}
        {!isLoading && !error && !info && (
             <p className="text-center text-gray-500 mt-8">Student information not found.</p>
        )}
    </div>
  );
}

export default StudentInfoScreen;
