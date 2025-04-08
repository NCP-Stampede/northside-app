import React, { useState, useEffect } from 'react';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import FlexItem from '../components/FlexItem'; // Import component
import { fetchFlexes } from '../services/api';

function FlexesScreen() {
    const [flexes, setFlexes] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true);
            setError(null);
            try {
                const data = await fetchFlexes();
                setFlexes(data);
            } catch (err) {
                setError("Failed to load Flex periods.");
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        };
        loadData();
    }, []);


    return (
        <div className="p-4">
            <header className="mb-6">
                <h1 className="text-2xl font-bold">Flexes</h1>
                {/* <div className="text-sm text-gray-500">Current Registration</div> */}
            </header>

            {isLoading && <LoadingSpinner />}
            {error && <ErrorMessage message={error} />}

            {!isLoading && !error && (
                <div>
                    {flexes.length > 0 ? (
                        flexes.map(flex => <FlexItem key={flex.id} {...flex} />)
                    ) : (
                        <p className="text-center text-gray-500 mt-8">No Flex periods found.</p>
                    )}
                </div>
            )}
        </div>
    );
}
export default FlexesScreen;
