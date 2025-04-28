import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from './models/User.js';
import Grade from './models/Grade.js';
import Event from './models/Event.js';
import Article from './models/Article.js';
import Flex from './models/Flex.js';
import Attendance from './models/Attendance.js';

// Load environment variables
dotenv.config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB for seeding'))
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

// Clear existing data
const clearData = async () => {
  await User.deleteMany({});
  await Grade.deleteMany({});
  await Event.deleteMany({});
  await Article.deleteMany({});
  await Flex.deleteMany({});
  await Attendance.deleteMany({});
  console.log('All collections cleared');
};

// Seed users
const seedUsers = async () => {
  const student = new User({
    username: 'student',
    password: 'password',
    name: 'John',
    role: 'student',
    studentInfo: {
      firstName: 'John',
      lastName: 'Appleseed',
      middleInitial: 'J',
      studentId: '1234567',
      grade: 'Sophomore',
      dob: new Date('2009-01-28'),
      school: 'Northside Prep',
      profilePicUrl: null
    }
  });

  await student.save();
  console.log('User created:', student.username);
  return student;
};

// Seed grades
const seedGrades = async (student) => {
  const grades = [
    {
      course: "HS1 Algebra 1",
      teacher: "Dr. Stanley",
      grade: "98",
      letterGrade: "A",
      student: student._id,
      categories: [
        { name: "Summative", percentage: 99, score: "A+" },
        { name: "Formative", percentage: 95, score: "A" },
        { name: "Homework", percentage: 100, score: "A+" }
      ],
      assignments: [
        { name: "Ch 1 Test", category: "Summative", dueDate: new Date('2024-07-25'), score: '95/100' },
        { name: "Lab 1", category: "Formative", dueDate: new Date('2024-07-20'), score: '8/10' }
      ]
    },
    {
      course: "HS1 US History",
      teacher: "Mr. Porter",
      grade: "85.5",
      letterGrade: "B",
      student: student._id,
      categories: [
        { name: "Summative", percentage: 88, score: "B+" },
        { name: "Formative", percentage: 80, score: "B-" },
        { name: "Participation", percentage: 90, score: "A-" }
      ],
      assignments: [
        { name: "Civil War Essay", category: "Summative", dueDate: new Date('2024-07-15'), score: '88/100' },
        { name: "Constitution Quiz", category: "Formative", dueDate: new Date('2024-07-10'), score: '80/100' }
      ]
    },
    {
      course: "HS1 AP Lang",
      teacher: "Mrs. Franklin",
      grade: "91.7",
      letterGrade: "A-",
      student: student._id,
      categories: [
        { name: "Essays", percentage: 90, score: "A-" },
        { name: "MC Tests", percentage: 94, score: "A" },
        { name: "Classwork", percentage: 92, score: "A-" }
      ],
      assignments: [
        { name: "Rhetoric Analysis", category: "Essays", dueDate: new Date('2024-07-18'), score: '90/100' },
        { name: "Vocabulary Quiz", category: "MC Tests", dueDate: new Date('2024-07-12'), score: '94/100' }
      ]
    },
    {
      course: "HS1 Physics",
      teacher: "Dr. George",
      grade: "93.2",
      letterGrade: "A",
      student: student._id,
      categories: [
        { name: "Labs", percentage: 95 },
        { name: "Tests", percentage: 92 }
      ],
      assignments: [
        { name: "Motion Lab", category: "Labs", dueDate: new Date('2024-07-22'), score: '95/100' },
        { name: "Newton's Laws Test", category: "Tests", dueDate: new Date('2024-07-17'), score: '92/100' }
      ]
    },
    {
      course: "HS1 Physical Education",
      teacher: "Coach Davis",
      grade: "100",
      letterGrade: "A+",
      student: student._id,
      categories: [
        { name: "Participation", percentage: 100 }
      ],
      assignments: [
        { name: "Fitness Test", category: "Participation", dueDate: new Date('2024-07-14'), score: '100/100' }
      ]
    },
    {
      course: "HS1 Colloquium",
      teacher: "Mr. Phillips",
      grade: "89",
      letterGrade: "B+",
      student: student._id,
      categories: [
        { name: "Presentations", percentage: 90 },
        { name: "Reflections", percentage: 88 }
      ],
      assignments: [
        { name: "Group Presentation", category: "Presentations", dueDate: new Date('2024-07-11'), score: '90/100' },
        { name: "Weekly Reflection", category: "Reflections", dueDate: new Date('2024-07-08'), score: '88/100' }
      ]
    },
    {
      course: "HS1 Art 1",
      teacher: "Ms. Wang",
      grade: "72",
      letterGrade: "C-",
      isFailing: true,
      student: student._id,
      categories: [
        { name: "Projects", percentage: 70, score: "C-" },
        { name: "Sketchbook", percentage: 75, score: "C" }
      ],
      assignments: [
        { name: "Self Portrait", category: "Projects", dueDate: new Date('2024-07-19'), score: '70/100' },
        { name: "Perspective Drawing", category: "Sketchbook", dueDate: new Date('2024-07-16'), score: '75/100' }
      ]
    }
  ];

  await Grade.insertMany(grades);
  console.log('Grades created');
};

// Seed events
const seedEvents = async () => {
  const today = new Date();
  const events = [
    {
      title: 'School Play Rehearsal',
      date: today,
      time: '3:00 PM - 5:00 PM',
      location: 'Auditorium',
      description: 'Rehearsal for the upcoming spring musical'
    },
    {
      title: 'Chess Club Meeting',
      date: today,
      time: '3:15 PM',
      location: 'Library',
      description: 'Weekly chess club meeting'
    },
    {
      title: 'Parent-Teacher Conference',
      date: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7),
      time: '4:00 PM - 7:00 PM',
      location: 'Main Hall',
      description: 'Spring semester parent-teacher conferences'
    },
    {
      title: 'Science Fair',
      date: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 14),
      time: '9:00 AM - 3:00 PM',
      location: 'Gymnasium',
      description: 'Annual science fair exhibition'
    }
  ];

  await Event.insertMany(events);
  console.log('Events created');
};

// Seed articles
const seedArticles = async () => {
  const articles = [
    {
      slug: 'building-damage-insights',
      title: 'Building Damage Insights from the Principal',
      author: 'Dr. Weissman',
      date: new Date(2024, 5, 18), // June 18, 2024
      image: '/api/placeholder/400/200',
      content: '<p>Detailed content about the recent building damage...</p><p>Further paragraphs go here.</p>',
      tag: 'HEADLINE'
    },
    {
      slug: 'gym-flooding',
      title: 'Flooding hits the new gymnasium',
      author: 'Campus News',
      date: new Date(2024, 5, 17), // June 17, 2024
      image: '/api/placeholder/100/100',
      content: '<p>Details about the gym flooding incident...</p>',
      tag: 'TRENDING'
    },
    {
      slug: 'pool-sharks',
      title: 'SHARKS!? In new swimming pool',
      author: 'Satire Dept.',
      date: new Date(2024, 5, 16), // June 16, 2024
      image: '/api/placeholder/100/100',
      content: '<p>Okay, not real sharks, but...</p>',
      tag: 'TRENDING'
    },
    {
      slug: 'spring-musical',
      title: 'The Spring Musical announcement',
      author: 'Arts Dept.',
      date: new Date(2024, 5, 15), // June 15, 2024
      image: '/api/placeholder/100/100',
      content: '<p>This year\'s spring musical will be...</p>',
      tag: 'TRENDING'
    },
    {
      slug: 'kahoot-reward-8',
      title: 'What\'s a Kahoot Worth 8 ratio completion reward?',
      author: 'Academics',
      date: new Date(2024, 5, 15), // June 15, 2024
      content: '<p>Details about the Kahoot rewards...</p>',
      tag: 'NEWS'
    },
    {
      slug: 'kahoot-reward-6',
      title: 'What\'s a Kahoot Worth 6 ratio completion reward?',
      author: 'Academics',
      date: new Date(2024, 5, 14), // June 14, 2024
      content: '<p>More details about Kahoot...</p>',
      tag: 'NEWS'
    },
    {
      slug: 'kahoot-reward-9',
      title: 'What\'s a Kahoot Worth 9 ratio completion reward?',
      author: 'Academics',
      date: new Date(2024, 5, 13), // June 13, 2024
      content: '<p>Even more details...</p>',
      tag: 'NEWS'
    }
  ];

  await Article.insertMany(articles);
  console.log('Articles created');
};

// Seed flexes
const seedFlexes = async () => {
  const flexes = [
    {
      name: 'Flex 2',
      status: 'available',
      options: [
        {
          title: 'Study Hall',
          room: 'Room 201',
          teacher: 'Ms. Johnson',
          capacity: 30,
          enrolled: []
        },
        {
          title: 'Math Help',
          room: 'Room 103',
          teacher: 'Mr. Smith',
          capacity: 20,
          enrolled: []
        },
        {
          title: 'Science Lab',
          room: 'Room 305',
          teacher: 'Dr. Miller',
          capacity: 15,
          enrolled: []
        },
        {
          title: 'Chess Club',
          room: 'Library',
          teacher: 'Mr. Thompson',
          capacity: 12,
          enrolled: []
        }
      ]
    },
    {
      name: 'Flex 3',
      status: 'available',
      options: [
        {
          title: 'Quiet Study',
          room: 'Room 101',
          teacher: 'Mr. Lee',
          capacity: 25,
          enrolled: []
        }
      ]
    },
    {
      name: 'Flex 4',
      status: 'upcoming',
      options: []
    }
  ];

  await Flex.insertMany(flexes);
  console.log('Flexes created');
};

// Seed attendance records
const seedAttendance = async (student) => {
  const attendance = [
    {
      student: student._id,
      date: new Date(2024, 2, 15), // March 15, 2024
      status: 'tardy',
      course: 'HS1 Algebra',
      teacher: 'Dr. George',
      time: '8:05 AM',
      details: 'Arrived 5 minutes late.',
      excused: false
    },
    {
      student: student._id,
      date: new Date(2024, 1, 28), // February 28, 2024
      status: 'tardy',
      course: 'HS1 Physics',
      teacher: 'Dr. George',
      time: '9:10 AM',
      details: 'Arrived 10 minutes late, missed quiz instructions.',
      excused: false
    },
    {
      student: student._id,
      date: new Date(2024, 3, 5), // April 5, 2024
      status: 'absent',
      course: 'HS1 US History',
      teacher: 'Mr. Porter',
      details: 'Full day absence',
      excused: true
    },
    {
      student: student._id,
      date: new Date(2024, 3, 10), // April 10, 2024
      status: 'absent',
      course: 'HS1 AP Lang',
      teacher: 'Mrs. Franklin',
      details: 'Full day absence',
      excused: false
    }
  ];

  // Add 31 present records
  for (let i = 0; i < 31; i++) {
    const date = new Date(2024, 2, i + 1); // March 2024
    if (![15].includes(i + 1)) { // Skip tardy days
      attendance.push({
        student: student._id,
        date,
        status: 'present',
        course: 'All courses',
        teacher: 'Multiple',
        excused: false
      });
    }
  }

  await Attendance.insertMany(attendance);
  console.log('Attendance records created');
};

// Run the seeding process
const seedDB = async () => {
  try {
    await clearData();
    const student = await seedUsers();
    await seedGrades(student);
    await seedEvents();
    await seedArticles();
    await seedFlexes();
    await seedAttendance(student);
    
    console.log('Database seeded successfully');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDB();