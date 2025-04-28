// API service with real backend implementation

// Helper for making API requests
const apiRequest = async (url, options = {}) => {
  try {
    // Get token from local storage if it exists
    const token = localStorage.getItem('auth_token');
    
    // Set default headers
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    };
    
    // Add auth token if available
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    
    // Make the request
    const response = await fetch(url, {
      ...options,
      headers
    });
    
    // Handle non-2xx responses
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `Request failed with status ${response.status}`);
    }
    
    // Parse and return JSON response
    return await response.json();
  } catch (error) {
    console.error(`API request error for ${url}:`, error);
    throw error;
  }
};

// --- AUTH ---
export const loginUser = async (username, password) => {
  return apiRequest('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ username, password })
  });
};

export const logoutUser = async () => {
  return apiRequest('/api/auth/logout', {
    method: 'POST'
  });
};

// --- GRADES ---
export const fetchGrades = async ({ filter } = {}) => {
  return apiRequest(`/api/grades?filter=${filter || ''}`);
};

export const fetchGradeDetails = async (courseId) => {
  return apiRequest(`/api/grades/${courseId}`);
};

// --- EVENTS ---
export const fetchEvents = async ({ month, year } = {}) => {
  const query = new URLSearchParams();
  if (month) query.append('month', month);
  if (year) query.append('year', year);
  
  return apiRequest(`/api/events?${query.toString()}`);
};

export const fetchEventDetails = async (eventDate) => {
  return apiRequest(`/api/events/${eventDate}`);
};

// --- ATHLETICS ---
export const fetchAthletics = async () => {
  // This endpoint would need to be implemented on the backend
  // Using mock data for now
  await new Promise(resolve => setTimeout(resolve, 700));
  return {
    featuredStory: { title: "Boys Basketball make it to state", description: "First time in school's history", image: "/api/placeholder/400/200" }
  };
};

export const fetchAllSports = async ({ filter = 'all' } = {}) => {
  // This endpoint would need to be implemented on the backend
  // Using mock data for now
  await new Promise(resolve => setTimeout(resolve, 600));
  const sports = [
    { id: 'baseball', name: "Baseball", season: 'Spring' },
    { id: 'cc', name: "Cross Country", season: 'Fall' },
    { id: 'lacrosse', name: "Lacrosse", season: 'Spring' },
    { id: 'soccer', name: "Soccer", season: 'Fall' },
    { id: 'golf', name: "Golf", season: 'Spring' },
    { id: 'softball', name: "Softball", season: 'Spring' },
    { id: 'cheer', name: "Cheer Leading", season: 'All' },
    { id: 'dance', name: "Dance", season: 'All' },
    { id: 'tennis', name: "Tennis", season: 'Fall' },
    { id: 'flagfootball', name: "Flag Football", season: 'Fall' },
    { id: 'swimming', name: "Swimming", season: 'Winter' },
    { id: 'volleyball', name: "VolleyBall", season: 'Winter' },
    { id: 'basketball', name: "Basketball", season: 'Winter' }
  ];
  if (filter === 'all') return sports;
  return sports.filter(s => s.season.toLowerCase() === filter.toLowerCase() || s.season === 'All');
};

export const fetchSportDetails = async (sportId) => {
  // This endpoint would need to be implemented on the backend
  // Using mock data for now
  await new Promise(resolve => setTimeout(resolve, 750));
  const sportData = {
    soccer: { id: 'soccer', name: 'Soccer (Boys)', coach: 'Mr. Davis', season: 'Fall', schedule: [ { opponent: 'North HS', date: '2024-09-10', location: 'Home', time: '4:00 PM', result: 'W 3-1' }, { opponent: 'West HS', date: '2024-09-15', location: 'Away', time: '4:30 PM' } ], roster: [ { name: 'Player One', number: 10, year: 'Jr' }, { name: 'Player Two', number: 7, year: 'Sr' } ], news: [{ id:'news1', title: 'Team wins opener!', date: '2024-09-11' }] },
    lacrosse: { id: 'lacrosse', name: 'Lacrosse (Girls)', coach: 'Ms. Evans', season: 'Spring', schedule: [ { opponent: 'South HS', date: '2025-04-05', location: 'Away' } ], roster: [ { name: 'Player A' }, { name: 'Player B' } ], news: [] }
  };
  const details = sportData[sportId];
  if (!details) throw new Error("Sport details not found.");
  return details;
};

export const fetchAthleticProfile = async () => {
  // This endpoint would need to be implemented on the backend
  // Using mock data for now
  await new Promise(resolve => setTimeout(resolve, 800));
  return {
    studentInfo: { firstName: "John", lastName: "Appleseed", id: "1234567" },
    physicalForms: { uploaded: true, expiryDate: "2025-06-30", status: 'verified' },
    emergencyContacts: [{ name: "Jane Appleseed", relationship: "Mother", phone: "555-123-4567" }],
    parentGuardianInfo: { name1: "Jane Appleseed", email1: "jane@example.com", phone1: "555-123-4567", address: { street: "123 Main St", city: "Chicago", state: "IL", zip: "60600" } }
  };
};

// --- HOOFBEAT ---
export const fetchHoofbeat = async () => {
  return apiRequest('/api/hoofbeat');
};

export const fetchArticleDetails = async (articleSlug) => {
  return apiRequest(`/api/hoofbeat/${articleSlug}`);
};

// --- FLEXES ---
export const fetchFlexes = async () => {
  return apiRequest('/api/flexes');
};

export const fetchFlexOptions = async (flexId) => {
  return apiRequest(`/api/flexes/${flexId}`);
};

export const registerForFlex = async (flexId, optionId) => {
  return apiRequest(`/api/flexes/${flexId}/${optionId}`, {
    method: 'POST'
  });
};

// --- PROFILE & SCHEDULE ---
export const fetchProfileData = async () => {
  return apiRequest('/api/profile');
};

export const fetchStudentInfo = async () => {
  return apiRequest('/api/profile/studentInfo');
};

export const fetchSchedule = async () => {
  return apiRequest('/api/profile/schedule');
};

// --- ATTENDANCE ---
export const fetchAttendance = async () => {
  return apiRequest('/api/attendance');
};

export const fetchTardyDetails = async (tardyId) => {
  return apiRequest(`/api/attendance/${tardyId}`);
};
