class AzanGuruQueries {

  static String fetchAppVersionsQuery = r'''
  query {
    appVersions {
      android
      ios
    }
  }
''';

  static String createAccount = r'''
mutation registerUserWithCustomMeta($username: String!, $password: String!, $email: String!, $firstName: String!, $phoneNumber: String!) {
  registerUserWithCustomMeta(input: {
  clientMutationId: "uniqueId",
    username: $username,
    password: $password,
    email: $email,
    phoneNumber: $phoneNumber,
    firstName: $firstName,
  }){
    user {
      id
      userId
      name
      email
      description
      firstName
      nickname
      nicename
      username
      locale
      phone
      studentsOptions {
        studentInappProductId
        studentPicture {
          node {
            mediaItemId
            mediaItemUrl
          }
        }
      }
    }
    roles {
      nodes {
        id
        name
      }
    }
    authToken
    refreshToken
     error
  }
}

''';

  static String resetPasswordEmail = r"""
mutation MyMutation($username: String!) {
  sendPasswordResetEmail(input: { username: $username }) {
    success
  }
}
""";

  // UPDATED: Now uses email instead of userId to match backend schema
  static const String getSubscriptionsByEmail = r'''
query GetSubscriptionsByEmail($email: String!) {
  getSubscriptions(email: $email) {
    orders {
      key
      value
    }
  }
}
''';

  static const String getSubscriptionsByUserId = r'''
query GetSubscriptionsByUserId($userId: Int!) {
  getSubscriptions(userId: $userId) {
    orders {
      key
      value
    }
  }
}
''';

  // NEW QUERY: Source of truth for course access
  static const String viewerCourseAccess = r'''
query ViewerCourseAccess {
  viewer {
    databaseId
    studentsOptions {
      studentCourse {
        nodes {
          id
        }
      }
    }
  }
}
''';

  static String submitQuiz = r'''
mutation SubmitQuiz ($lessonId: Int!, $studentId: Int!,$quizzId:Int!,$quizAnswers:String!){
  submitQuiz(
    input: {lessonId: $lessonId, studentId: $studentId, quizzId: $quizzId, quizAnswers: $quizAnswers}
  ) {
    error
    message
    clientMutationId
  }
}
  ''';

  static String submitQuizNew = '''
mutation SubmitQuiz(\$input: SubmitQuizInput!) {
  submitQuiz(input: \$input) {
    error
    message
  }
}
''';

  static String loginUser = r'''
mutation MyMutation($username: String!, $password: String!) {
  login(input: {password: $password, username: $username}) {
    authToken
    clientMutationId
    refreshToken
    user {
      avatar {
        url
      }
      email
      gender
      description
      firstName
      id
      databaseId
      lastName
      name
      nicename
      nickname
      username
      locale
      phone
      studentsOptions {
       studentInappProductId
      }
      generalUserOptions {
       agUserAuthKey
      }
      roles {
        nodes {
          id
          name
        }
      }
    }
  }
}
''';

  static const String refreshToken = r'''
mutation RefreshToken($refreshToken: String!) {
  refreshToken(refreshToken: $refreshToken) {
    authToken
    refreshToken
  }
}
''';

  static String sendQuestionByEmail = r'''
mutation MyMutation($email: String!,$description: String!,$subject: String!,$title:String!, $phone: String!) {
  sendQuestionByEmail(input: {email: $email, phone: $phone, description: $description, subject: $subject, title: $title}) {
  clientMutationId
  error
  success
  }
}  
  ''';

  static String agHelpDesks = """
query GetAGHelpDesks(\$search: String!) {
  agHelpDesks(first: 500,where: {search: \$search}) {
    nodes {
      id
      title
      date
    }
  }
}
  """;

  static String getSubscriptions = """
  query GetSubscriptions(\$email: String!) {
    getSubscriptions(email: \$email) {
        orders {
          key
          value
        }
    }
  }
""";

  static String getOrderStatus = """
    query getSubscriptions(\$email: String!) {
      getSubscriptions(email: \$email) {
        orders {
          key
          value
        }
        number
        error
      }
    }
  """;

  static String agHelpDeskBy = """
 query GetAgHelpDeskBy(\$id: ID!){
  agHelpDeskBy(id: \$id) {
    id
    title
    date
    helpDesk {
      helpDeskText
      helpDeskVideoSection {
        videoFile {
          node {
            mediaItemId
            mediaItemUrl
            mediaType
          }
        }
        videoFileUrl
      }
      helpDeskImageSection {
        helpDeskImage {
          node {
            mediaItemId
            mediaItemUrl
          }
        }
      }
      helpDeskAudioSection {
        helpDeskAudio {
          node {
            mediaItemId
            mediaItemUrl
          }
        }
      }
    }
  }
}
""";

  static String getChooseCourses = """
query NewQuery {
  agQuestions(where: {orderby: {field: DATE, order: ASC}}) {
    nodes {
      id
      title
      date
      agQuestionId
      chooseYourCourse {
        alphabetOrderWordOrder
        alphabets
        questionType
        options {
          option
          questionIcon
          audioOption {
            node {
              mediaItemUrl
              mediaItemId
            }
          }
          nextQuestion {
            nodes {
              slug
              id
            }
          }
          showCourse {
            nodes {
              id
              name
              description
              ... on AgCourseCategory {
                id
                name
                courseTypeImage {
                  courseCategoryImage {
                    node {
                      mediaItemId
                      mediaItemUrl
                    }
                  }
                  chooseCourseInfo
                }
              }
            }
          }
        }
        questionInUrdu
        questionAudio {
          node {
            title
            mediaItemId
            mediaItemUrl
          }
        }
        correctAlphabetNextQuestion {
          edges {
            node {
              slug
              id
            }
          }
        }
        correctAlphabetOrder {
          edges {
            node {
              slug
              id
            }
          }
        }
        incorectAlphabetNextQuestion {
          edges {
            node {
             slug
             id
            }
          }
        }
        incorrectAlphabetOrder {
          edges {
            node {
              id
              name
              description
              ... on AgCourseCategory {
                id
                name
                courseTypeImage {
                  courseCategoryImage {
                    node {
                      mediaItemId
                      mediaItemUrl
                    }
                  }
                  chooseCourseInfo
                }
              }
            }                 
          }       
        }
      }
    }
  }
}
""";

  static String deleteUser = r'''
mutation DeleteUser($id: ID!){
  deleteUser(input: {id: $id}) {
    user {
      email
      id
      username
    }
  }
}
''';

  static String getUser = """
  query GetUser(\$id: ID!) {
    user(id: \$id) {
      avatar {
        url
      }
      email
      gender
      description
      firstName
      id
      databaseId
      lastName
      name
      nicename
      nickname
      username
      locale
      phone
      generalUserOptions {
        phoneNumber
        agUserAuthKey
      }
      studentsOptions {
      studentInappProductId
        studentPicture {
          node {
            mediaItemId
            mediaItemUrl
          }
        }
      }
      roles {
        nodes {
          id
          name
        }
      }
    }
  }
""";

  static String agNotificationsList = r"""
query AgNotificationsList{
  agNotifications {
    nodes {
      id
      title
      date
       notifications {
        notificationType
      } 
    }
  }
}
  """;

  static String lessonProgressUpdate = r'''
  query Users {
    users {
      nodes {
        id
        username
        email
        studentsOptions {
          studentAge
          studentBatch
          studentCourse {
            edges {
              node {
                id
                name
               }
            }
          }
          studentCompletedLessons {
            nodes {
              id
            }
          }
          studentCompletedQuizzes
          studentProgress
        }
      }
    }
  }
''';

  static String updateUser = r'''
mutation MyMutation($id: ID!, $email: String!,$firstName: String!,$lastName: String!,$phone: String!,$gender: String!,) {
  updateUser(input: {clientMutationId: "uniqueId", id: $id, email: $email, firstName: $firstName,lastName: $lastName,phone: $phone, gender: $gender,}) {
     user {
      avatar {
        url
      }
      email
      databaseId
      description
      firstName
      id
      lastName
      name
      nicename
      nickname
      username
      locale
      phone
      gender
    }
  }
}
''';

  static String submitHomeworkMutation = r"""
mutation SubmitHomework($file: Upload!,$homeworkId: Int!,$lessonId: Int!,$studentId: Int!) {
  submitHomework(input: {file: $file,homeworkId: $homeworkId,lessonId: $lessonId,studentId: $studentId}) {
    error
    message
    user {
      id
    }
  }
}
""";

  static String uploadImage = r"""
mutation ($file: Upload!, $studentId: ID!) { 
  updateUserPicture(input: {studentId: $studentId, file: $file}) { 
    user { 
      id 
    } 
    error 
    message
  }
}
""";

  static String getSubmittedQuizzAnswers = """
    query getQuizz(\$userId: Int!, \$lessonId: Int!) {
      getQuizz(userId: \$userId, lessonId: \$lessonId) {
        data {
          key
          value
        }
        error
      }
    }
  """;

  static String submitLesson = r"""
mutation SubmitCompletedLesson($lesson_id: String!,$student_id: String!) {
  submitCompletedLesson(input: {lesson_id: $lesson_id,student_id: $student_id}) {
    success
    error
  }
}
""";

  static String getCategoryWiseCourseListing = r'''
query NewQuery {
  agCourseCategories {
    nodes {
      id
      name
      description
      count
      databaseId
      courseTypeImage {
        courseCategoryImage {
          node {
            mediaItemUrl
          }
        }
        courseHours
      }
      agCourses {
        nodes {
          id
          agCourseId
          title
          lessonVideo {
            video {
              node {
                mediaItemUrl
                status
                date
              }
            }
          }
          preview {
            node {
              agCourseId
              lessonVideo {
                video {
                  node {
                    mediaItemUrl
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

  // UPDATED: Using idType: DATABASE_ID
  static String myCourse = """
query MyQuery(\$id: ID!) {
  user(id: \$id, idType: DATABASE_ID) {
    id
    name
    studentsOptions {
      studentAge
      studentBatch
      studentProgress
      studentUpdatedTime
      studentCompletedQuizzes
      studentCompletedLessons(first:250) {
        nodes {
          id
        }
      }
      studentCourse {
        nodes {
          name
          id
          count
            ... on AgCourseCategory {
            id
            name
            courseTypeImage {
              courseCategoryImage {
                node {
                  mediaItemId
                  mediaItemUrl
                }
              }
            }
          }
        }
      }
    }
  }
}
""";

  static String getCourseDetail = """
query GetCourseCategory(\$id: ID!) {
  agCourseCategory(id: \$id) {
    id
    count
    databaseId
    name
    description
    courseTypeImage {
      courseCategoryImage {
        node {
          date
          mediaItemId
          mediaItemUrl
        }
      }
      courseHours
      coursePrice
      coursePreview {
        node {
          mediaItemId
          mediaItemUrl
        }
      }
      coursePreviewUrl
    }
  }
}
""";

  static String getLessonsList = """
query GetAgCourseCategoryPosts(\$id: ID!) {
  agCourseCategoryPosts(id: \$id) {
    nodes {
      id
      title
      date
      completed
      lessonVideo {
        videoDetails
        nextLesson {
          edges {
            node {
              id
              databaseId
              slug
              date
            }
          }
        }
      }
    }
  }
}
""";

  static String getLessonsListOld = """
query GetCourseCategory(\$id: ID!) {
  agCourseCategory(id: \$id) {
    agCourses(first: 500,where: {orderby: {field: DATE, order: ASC}}) {
      nodes {
        id
        title
        date
        lessonVideo {
          videoDetails
          nextLesson {
            edges {
              node {
                id
                databaseId
                slug
                date
              }
            }
          }
        }
      }
    }
  }
}
""";

  static String liveClass = r'''
query NewQuery {
  generalOptions {
    id
    generalOptionsFields {
      liveClassesLink {
        title
        url
      }
      askToLiveTeacher
      liveClassInfoSection {
        availableForNonSubscribers
        whichDay
        addMoreRanges {
          endTime
          startTime
        }
      }
    }
  }
}
''';

  static String freeQuranList = r'''
 query NewQuery {
  agListenQurans(first: 500) {
    nodes {
      id
      databaseId
      date
      title
      listenQuran {
        listenQuranDescription
        quranAudio {
          node {
            mediaItemId
            mediaItemUrl
            description
          }
        }
      }
    }
  }
}
''';

  static String updateDeviceToken = '''
        mutation UpdateUserDeviceToken(\$userId: ID!, \$deviceToken: String!) {
          updateUserDeviceToken(input: {userId: \$userId, deviceToken: \$deviceToken}) {
            success
            user {
              id
              name
              email
            }
            error
          }
        }
      ''';

  static String getCourseAmount = '''
mutation MyMutation {
  getProductPriceFromACF(input: {clientMutationId: ""}) {
    clientMutationId
    discountedPrice
    regularPrice
    salePrice
  }
}
''';

  static String getLessonDetail = """
query MyQuery(\$id: ID!) {
  agCourseBy(id: \$id) {
    id
    title
    date
    databaseId
    lessonVideo {
      videoDetails
      streamVideoUrl
      video {
        node {
          mediaItemId
          mediaItemUrl
        }
      }
      homeWork {
        nodes {
          ... on AgHomeWork {
            id
            title
            date
            databaseId
            lessonHomeWork {
              audioRecordingFromStudent
              homeWorkType {                
                audios {
                  audio {
                    node {
                      id
                      mediaItemId
                      mediaItemUrl
                      mediaType
                      date
                    }
                  }
                }
                videos {
                  streamVideoUrl
                  video {
                    node {
                      mediaItemId
                      mediaItemUrl
                    }
                  }
                }
                images {
                  image {
                    node {
                      mediaItemId
                      mediaItemUrl
                    }
                  }
                }
              }
            }
          }
        }
      }
      quizzes {
        nodes {
          ... on AgQuizCategory {
            agQuizzes {
              nodes {
                id
                title
            		databaseId
                lessonQuiz {
                  createYourQuiz {
                    options {
                      value
                    }
                    quizNameAudio {
                      node {
                        mediaItemId
                        mediaItemUrl
                      }
                    }
                    quizImage {
                      node {
                        mediaItemId
                        mediaItemUrl
                      }
                    }
                    quizType
                    answer
                    audios {
                      audio {
                        node {
                          mediaItemId
                          mediaItemUrl
                          title
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      nextLesson {
        nodes {
          id
          databaseId
          slug
          date
        }
      }
    }
  }
}
""";

  // Forgot Password Mutations
  static String sendForgotPasswordOtp = r"""
mutation SendForgotPasswordOtp($email: String!) {
  sendForgotPasswordOtp(input: { email: $email }) {
    success
    message
  }
}
""";

  static String verifyForgotPasswordOtp = r"""
mutation VerifyForgotPasswordOtp($email: String!, $otp: String!) {
  verifyForgotPasswordOtp(input: { email: $email, otp: $otp }) {
    success
    message
    otpToken
  }
}
""";

  static String updatePasswordAfterOtp = r"""
mutation UpdatePasswordAfterOtp($email: String!, $newPassword: String!, $otpToken: String!) {
  updatePasswordAfterOtp(input: { email: $email, newPassword: $newPassword, otpToken: $otpToken }) {
    success
    message
    user {
      id
      userId
      email
      username
    }
  }
}
""";

}
