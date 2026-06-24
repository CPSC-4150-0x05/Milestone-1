# Milestone 2

## What's Implemented
- **Login/Signup**  
  Created class code system. When teacher sign up, receive a class code in their dashboard screen. When students sign up, they will need a class code from their teacher to make an account. This is to connect teachers with their students
- **WordList**  
  Implemented the dolch list from announcments. Edited the CSV file and wordlist class to include priority, I added a way for the teacher to rearrange the priority on the wordlist page by dragging the lists up and down and it saves even after restart. I moved the wordlist page to the teacher side and when clicked on the list of words still pops up (the old buttons are still there) the students are redirected to the top priority list as of right now but I'm okay with that being changed later. Also for right now I just added a button to get to the wordlist from the teacher dashboard that can also be changed I just needed a way to access it.
- **Practice**  
  Words get removed from the list when they are correctly pronounced. Whether right or wrong, the word moves on to the next word. When all words have been correctly pronounced, word list goes to celebration screen.
- **Progress**  
  Students can see progress on the progress page. Implemented progress bar and can see which words students have gotten correct and which words students need to work on.
- **Teacher Dashboard**
  The teacher dashboard will show class average and each student with their progress. Progress is basically calculated by number of successes by number of attempts. You can filter by student name and progress.