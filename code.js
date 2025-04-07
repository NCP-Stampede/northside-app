// Simulate API delay
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// --- AUTH ---
export const loginUser = async (username, password) => {
    await delay(1000);
    if (username === 'student' && password === 'password') {
        return { success: true, token: 'fake-jwt-token', user: { name: 'John', role: 'student' } };
    }
    throw new Error("Invalid username or password");
};

export const logoutUser = async () => {
    await delay(200);
    return { success: true };
};


// --- GRADES ---
export const fetchGrades = async ({ filter } = {}) => {
    console.log(`Fetching grades with filter: ${filter}`);
    await delay(800);
    const allGrades = [
        { id: 'alg1', course: "HS1 Algebra 1", teacher: "Dr. Stanley", grade: "98", letterGrade: "A" },
        { id: 'ush', course: "HS1 US History", teacher: "Mr. Porter", grade: "85.5", letterGrade: "B" },
        { id: 'aplang', course: "HS1 AP Lang", teacher: "Mrs. Franklin", grade: "91.7", letterGrade: "A-" },
        { id: 'phys', course: "HS1 Physics", teacher: "Dr. George", grade: "93.2", letterGrade: "A" },
        { id: 'pe', course: "HS1 Physical Education", teacher: "Coach Davis", grade: "100", letterGrade: "A+" },
        { id: 'coll', course: "HS1 Colloquium", teacher: "Mr. Phillips", grade: "89", letterGrade: "B+" },
        { id: 'art1', course: "HS1 Art 1", teacher: "Ms. Wang", grade: "72", letterGrade: "C-", isFailing: true },
    ];
    // Example filtering
    if (filter === 'currentTerm') {
        return allGrades.slice(0, 4);
    }
    return allGrades;
};

export const fetchGradeDetails = async (courseId) => {
    await delay(700);
    console.log(`Fetching grade details for course: ${courseId}`);
    const gradeMap = {
        alg1: { id: 'alg1', courseName: "HS1 Algebra 1", teacher: "Dr. Stanley", overallPercentage: 98.6, categories: [ { name: "Summative", percentage: 99, score: "A+" }, { name: "Formative", percentage: 95, score: "A" }, { name: "Homework", percentage: 100, score: "A+" }, ] },
        ush: { id: 'ush', courseName: "HS1 US History", teacher: "Mr. Porter", overallPercentage: 85.5, categories: [ { name: "Summative", percentage: 88, score: "B+" }, { name: "Formative", percentage: 80, score: "B-" }, { name: "Participation", percentage: 90, score: "A-" } ] },
        aplang: { id: 'aplang', courseName: "HS1 AP Lang", teacher: "Mrs. Franklin", overallPercentage: 91.7, categories: [ { name: "Essays", percentage: 90, score: "A-" }, { name: "MC Tests", percentage: 94, score: "A" }, { name: "Classwork", percentage: 92, score: "A-" } ] },
        phys: { id: 'phys', courseName: "HS1 Physics", teacher: "Dr. George", overallPercentage: 93.2, categories: [ { name: "Labs", percentage: 95 }, {name: "Tests", percentage: 92} ] },
        pe: { id: 'pe', courseName: "HS1 Physical Education", teacher: "Coach Davis", overallPercentage: 100, categories: [ {name: "Participation", percentage: 100} ] },
        coll: { id: 'coll', courseName: "HS1 Colloquium", teacher: "Mr. Phillips", overallPercentage: 89, categories: [ {name: "Presentations", percentage: 90}, {name: "Reflections", percentage: 88} ] },
        art1: { id: 'art1', courseName: "HS1 Art 1", teacher: "Ms. Wang", overallPercentage: 72.3, isFailing: true, categories: [ { name: "Projects", percentage: 70, score: "C-" }, { name: "Sketchbook", percentage: 75, score: "C" } ] },
    };
    const details = gradeMap[courseId];
    if (!details) throw new Error("Grade details not found for this course.");
    details.assignments = [ { id: 'assign1', name: `Ch ${courseId} Test`, category: 'Summative', dueDate: '2024-07-25', score: '95/100' }, { id: 'assign2', name: `Lab ${courseId}`, category: 'Formative', dueDate: '2024-07-20', score: '8/10' } ];
    return details;
};

// --- EVENTS ---
export const fetchEvents = async ({ month, year } = {}) => { // Add params
    await delay(600);
    console.log(`Fetching events for ${month}/${year}`);
    // Return mock event data (or fetch from API) - Needs better implementation for real calendar
    return {
        // Data related to events for the fetched month/year
    };
};

export const fetchEventDetails = async (eventDate) => { // Using date YYYY-MM-DD as ID
    await delay(500);
    console.log(`Fetching events for date: ${eventDate}`);
    const events = {
        // Example date corresponding to static calendar's "Today"
        [`${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, '0')}-${String(new Date().getDate()).padStart(2, '0')}`]: [
             { id: 'ev1', title: 'School Play Rehearsal', time: '3:00 PM - 5:00 PM', location: 'Auditorium' },
             { id: 'ev2', title: 'Chess Club Meeting', time: '3:15 PM', location: 'Library' },
        ],
        // Add more dates/events
    };
    return events[eventDate] || [];
};

// --- ATHLETICS ---
export const fetchAthletics = async () => {
    await delay(700);
    return {
        featuredStory: { title: "Boys Basketball make it to state", description: "First time in school's history", image: "/api/placeholder/400/200" },
        // sports: [{ name: "Baseball" }, { name: "Cross Country" }, { name: "Lacrosse" }, { name: "Soccer" }] // Maybe remove if All Sports link is primary
    };
};

export const fetchAllSports = async ({ filter = 'all' } = {}) => {
    await delay(600);
    console.log(`Fetching all sports with filter: ${filter}`);
    const sports = [
        { id: 'baseball', name: "Baseball", season: 'Spring' }, { id: 'cc', name: "Cross Country", season: 'Fall' }, { id: 'lacrosse', name: "Lacrosse", season: 'Spring' }, { id: 'soccer', name: "Soccer", season: 'Fall' }, { id: 'golf', name: "Golf", season: 'Spring' }, { id: 'softball', name: "Softball", season: 'Spring' }, { id: 'cheer', name: "Cheer Leading", season: 'All' }, { id: 'dance', name: "Dance", season: 'All' }, { id: 'tennis', name: "Tennis", season: 'Fall' }, { id: 'flagfootball', name: "Flag Football", season: 'Fall' }, { id: 'swimming', name: "Swimming", season: 'Winter' }, { id: 'volleyball', name: "VolleyBall", season: 'Winter' }, { id: 'basketball', name: "Basketball", season: 'Winter' },
    ];
    if (filter === 'all') return sports;
    return sports.filter(s => s.season.toLowerCase() === filter.toLowerCase() || s.season === 'All');
};

export const fetchSportDetails = async (sportId) => {
    await delay(750);
    console.log(`Fetching details for sport: ${sportId}`);
    const sportData = {
        soccer: { id: 'soccer', name: 'Soccer (Boys)', coach: 'Mr. Davis', season: 'Fall', schedule: [ { opponent: 'North HS', date: '2024-09-10', location: 'Home', time: '4:00 PM', result: 'W 3-1' }, { opponent: 'West HS', date: '2024-09-15', location: 'Away', time: '4:30 PM' } ], roster: [ { name: 'Player One', number: 10, year: 'Jr' }, { name: 'Player Two', number: 7, year: 'Sr' } ], news: [{ id:'news1', title: 'Team wins opener!', date: '2024-09-11' }] },
        lacrosse: { id: 'lacrosse', name: 'Lacrosse (Girls)', coach: 'Ms. Evans', season: 'Spring', schedule: [ { opponent: 'South HS', date: '2025-04-05', location: 'Away' } ], roster: [ { name: 'Player A' }, { name: 'Player B' } ], news: [] },
        // Add other sports
    };
    const details = sportData[sportId];
    if (!details) throw new Error("Sport details not found.");
    return details;
};

export const fetchAthleticProfile = async () => {
    await delay(800);
    return {
        studentInfo: { firstName: "John", lastName: "Appleseed", id: "1234567" },
        physicalForms: { uploaded: true, expiryDate: "2025-06-30", status: 'verified' },
        emergencyContacts: [{ name: "Jane Appleseed", relationship: "Mother", phone: "555-123-4567" }],
        parentGuardianInfo: { name1: "Jane Appleseed", email1: "jane@example.com", phone1: "555-123-4567", address: { street: "123 Main St", city: "Chicago", state: "IL", zip: "60600" } },
    };
};

// --- HOOFBEAT ---
export const fetchHoofbeat = async () => {
    await delay(900);
    return {
        headline: { id: 'building-damage-insights', slug: 'building-damage-insights', title: "Building Damage Insights from the Principal", author: "Dr. Weissman", image: "/api/placeholder/400/200", tag: "HEADLINE" },
        trending: [ { id: 't1', slug: 'gym-flooding', image: "/api/placeholder/100/100", title: "Flooding hits the new gymnasium" }, { id: 't2', slug: 'pool-sharks', image: "/api/placeholder/100/100", title: "SHARKS!? In new swimming pool" }, { id: 't3', slug: 'spring-musical', image: "/api/placeholder/100/100", title: "The Spring Musical announcement" } ],
        news: [ { id: 'n1', slug: 'kahoot-reward-8', title: "What's a Kahoot Worth 8 ratio completion reward?" }, { id: 'n2', slug: 'kahoot-reward-6', title: "What's a Kahoot Worth 6 ratio completion reward?" }, { id: 'n3', slug: 'kahoot-reward-9', title: "What's a Kahoot Worth 9 ratio completion reward?" } ]
    };
};

export const fetchArticleDetails = async (articleSlug) => {
    await delay(600);
    console.log(`Fetching article details for: ${articleSlug}`);
    const articles = {
        'building-damage-insights': { slug: 'building-damage-insights', title: "Building Damage Insights from the Principal", author: "Dr. Weissman", date: '2024-06-18', image: "/api/placeholder/400/200", content: "<p>Detailed content about the recent building damage...</p><p>Further paragraphs go here.</p>" },
        'gym-flooding': { slug: 'gym-flooding', title: "Flooding hits the new gymnasium", author: "Campus News", date: '2024-06-17', image: "/api/placeholder/400/200", content: "<p>Details about the gym flooding incident...</p>" },
         'pool-sharks': { slug: 'pool-sharks', title: "SHARKS!? In new swimming pool", author: "Satire Dept.", date: '2024-06-16', image: "/api/placeholder/400/200", content: "<p>Okay, not real sharks, but...</p>" },
         'kahoot-reward-8': { slug: 'kahoot-reward-8', title: "What's a Kahoot Worth 8 ratio completion reward?", author: "Academics", date: '2024-06-15', content: "<p>Details about the Kahoot rewards...</p>"},
         'kahoot-reward-6': { slug: 'kahoot-reward-6', title: "What's a Kahoot Worth 6 ratio completion reward?", author: "Academics", date: '2024-06-14', content: "<p>More details about Kahoot...</p>"},
         'kahoot-reward-9': { slug: 'kahoot-reward-9', title: "What's a Kahoot Worth 9 ratio completion reward?", author: "Academics", date: '2024-06-13', content: "<p>Even more details...</p>"},
    };
     const article = articles[articleSlug];
     if (!article) throw new Error("Article not found.");
     return article;
};

// --- FLEXES ---
export const fetchFlexes = async () => {
    await delay(550);
    return [ { id: 'flex2', name: 'Flex 2', status: 'available' }, { id: 'flex3', name: 'Flex 3', status: 'available' }, { id: 'flex4', name: 'Flex 4', status: 'upcoming' }, ];
};

export const fetchFlexOptions = async (flexId) => {
    await delay(450);
    console.log("Fetching options for flex:", flexId);
    const flexOptionsMap = {
        flex1: { name: "Flex 1", options: [ { id: 'f1opt1', title: "Reading Group", room: "Library", teacher: "Ms. Debye" }, /*...*/ ] },
        flex2: { name: "Flex 2", options: [ { id: 'f2opt1', title: "Study Hall", room: "Room 201", teacher: "Ms. Johnson" }, { id: 'f2opt2', title: "Math Help", room: "Room 103", teacher: "Mr. Smith" }, { id: 'f2opt3', title: "Science Lab", room: "Room 305", teacher: "Dr. Miller" }, { id: 'f2opt4', title: "Chess Club", room: "Library", teacher: "Mr. Thompson" }, ] },
        flex3: { name: "Flex 3", options: [ {id: 'f3opt1', title: 'Quiet Study', room: 'Room 101', teacher: 'Mr. Lee'} ] },
        flex4: { name: "Flex 4", options: [] }, // Upcoming example
    };
    const data = flexOptionsMap[flexId];
    if (!data) return { name: `Flex ${flexId.slice(-1)}`, options: [], status: 'upcoming' }; // Default for non-existent or upcoming
    return {...data, status: 'available'}; // Add status if needed
};

export const registerForFlex = async (flexId, optionId) => {
    await delay(1200);
    console.log(`Registering for Flex ${flexId} with Option ${optionId}`);
    if (Math.random() < 0.2) throw new Error("Registration failed: Slot is full.");
    return { success: true, message: `Successfully registered.` };
};

// --- PROFILE & SCHEDULE ---
export const fetchProfileData = async () => { // For ProfileScreen Header
    await delay(500);
    return { name: "John", gradeLevel: "Sophomore", school: "Northside Prep", profilePicUrl: null }; // Add profile pic URL later
};

export const fetchStudentInfo = async () => { // For StudentInfoScreen
    await delay(400);
    return { firstName: "John", lastName: "Appleseed", middleInitial: "J", studentId: "1234567", grade: "10", dob: "01/28/2009" };
};

export const fetchSchedule = async () => {
    await delay(650);
    const today = new Date(); // Make date dynamic
    return {
        date: today.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' }),
        blocks: [ { id: "b1", number: "1", course: "HS1 Algebra 1", courseId: "alg1" }, { id: "b2", number: "2", course: "HS1 US History", courseId: "ush" }, { id: "bC", number: "C", course: "HS1 AP Lang", courseId: "aplang" }, { id: "bD", number: "D", course: "Student Meal", courseId: null }, { id: "b4", number: "4", course: "HS1 Physics", courseId: "phys" }, ]
    };
};

// --- ATTENDANCE ---
export const fetchAttendance = async () => {
    await delay(750);
    return {
        summary: { present: 31, tardy: 5, absent: 2 }, // Example counts
        tardies: [ { id: 'tardy1', course: "HS1 Algebra", teacher: "Dr. George", date: "March 15" }, { id: 'tardy2', course: "HS1 Physics", teacher: "Dr. George", date: "February 28" }, ]
    };
};

export const fetchTardyDetails = async (tardyId) => {
    await delay(400);
    console.log(`Fetching details for tardy: ${tardyId}`);
    const tardies = {
        'tardy1': { id: 'tardy1', course: "HS1 Algebra", teacher: "Dr. George", date: "March 15", time: "8:05 AM", details: "Arrived 5 minutes late.", excused: false },
        'tardy2': { id: 'tardy2', course: "HS1 Physics", teacher: "Dr. George", date: "February 28", time: "9:10 AM", details: "Arrived 10 minutes late, missed quiz instructions.", excused: false },
    };
    const details = tardies[tardyId];
    if (!details) throw new Error("Tardy record not found.");
    return details;
};