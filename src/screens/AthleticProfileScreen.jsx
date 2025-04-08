import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchAthleticProfile } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import InfoSection from '../components/InfoSection'; // Reusable component
import InfoPair from '../components/InfoPair'; // Reusable component
import { ChevronLeft, CheckCircle, AlertCircle, Upload } from 'lucide-react';

function AthleticProfileScreen() {
    const navigate = useNavigate();
    const [profile, setProfile] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true);
            setError(null);
            try {
                const data = await fetchAthleticProfile();
                setProfile(data);
            } catch (err) {
                setError("Failed to load athletic profile.");
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        };
        loadData();
    }, []);

    const formatAddress = (addr) => {
        if (!addr) return '-';
        return `${addr.street || ''}, ${addr.city || ''}, ${addr.state || ''} ${addr.zip || ''}`.replace(/,\s*,/, ','); // Clean up missing parts
    }

    return (
        <div className="p-4">
             <header className="flex items-center mb-4 -ml-1">
                <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" aria-label="Go back">
                    <ChevronLeft size={24} className="text-blue-600" />
                </button>
                <h1 className="text-xl font-bold ml-2">Athletic Profile</h1>
            </header>

            {isLoading && <LoadingSpinner />}
            {error && <ErrorMessage message={error} />}

            {!isLoading && !error && profile && (
                <div>
                    {/* --- Student Info Section --- */}
                    <InfoSection title="Student Information">
                       <InfoPair label="First Name" value={profile.studentInfo?.firstName} />
                       <InfoPair label="Last Name" value={profile.studentInfo?.lastName} />
                       <InfoPair label="Student ID" value={profile.studentInfo?.id} />
                    </InfoSection>

                    {/* --- Physical Forms Section --- */}
                    <InfoSection title="Physical Forms">
                         <div className="flex items-center justify-between">
                            <div>
                                <InfoPair label="Status" value={profile.physicalForms?.uploaded ? 'Uploaded & Verified' : 'Not Uploaded'} />
                                {profile.physicalForms?.uploaded && <InfoPair label="Expires" value={profile.physicalForms?.expiryDate ? new Date(profile.physicalForms.expiryDate + 'T00:00:00').toLocaleDateString() : '-'} />}
                            </div>
                            {profile.physicalForms?.uploaded ? (
                                <CheckCircle className="w-8 h-8 text-green-500 flex-shrink-0" />
                            ) : (
                                // Basic upload button - needs functionality
                                <button className="bg-blue-500 text-white px-3 py-1 rounded text-sm flex items-center hover:bg-blue-600 flex-shrink-0">
                                     <Upload size={14} className="mr-1"/> Upload
                                </button>
                            )}
                        </div>
                        {/* Add other form elements like concussion waivers if in Figma */}
                    </InfoSection>

                    {/* --- Parent/Guardian Info Section --- */}
                    <InfoSection title="Parent/Guardian Information">
                        <InfoPair label="Name" value={profile.parentGuardianInfo?.name1} />
                        <InfoPair label="Email" value={profile.parentGuardianInfo?.email1} />
                        <InfoPair label="Phone" value={profile.parentGuardianInfo?.phone1} />
                         <InfoPair label="Address" value={formatAddress(profile.parentGuardianInfo?.address)} />
                        {/* Add second parent/guardian if applicable */}
                    </InfoSection>

                    {/* --- Emergency Contacts Section --- */}
                     <InfoSection title="Emergency Contacts">
                         {profile.emergencyContacts?.length > 0 ? (
                            profile.emergencyContacts.map((contact, index) => (
                                <div key={index} className="pb-2 mb-2 border-b last:border-b-0 last:pb-0 last:mb-0">
                                    <InfoPair label="Name" value={contact.name} />
                                    <InfoPair label="Relationship" value={contact.relationship} />
                                    <InfoPair label="Phone" value={contact.phone} />
                                </div>
                             ))
                         ) : <InfoPair label="Contacts" value="No emergency contacts listed." /> }
                     </InfoSection>

                     {/* Add other sections as needed based on Figma (e.g., Insurance, Agreements) */}
                </div>
            )}
            {!isLoading && !error && !profile && (
                 <p className="text-center text-gray-500 mt-8">Athletic profile not found.</p>
            )}
        </div>
    );
}
export default AthleticProfileScreen;
