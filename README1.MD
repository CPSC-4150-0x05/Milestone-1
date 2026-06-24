# Milestone 1

## What's Implemented
- **Login/Signup**  
  Account creation for teachers and students. Created the login and sign up screens. Create user object and store user data in SQlite database. Used Shared preferences for persistence. Signup screen has checks that require emails to have an '@' and password length atleast 8 characters.
- **WordList**  
  Select the word list for seed_words.csv. After selecting a list can select a word to practice on. Edited the wordlist selection page, made the model for the word lists, added another list to the csv file and created a service that made it easy to pull information directly from the csv.
- **Practice**  
  Use the record button to record up to 7 seconds. Student's speech to text gets compared to the actual word. The student gets instant feedback via either a green splash screen with a checkmark or an orange one with a circular arrow to retry. If the attempt was successful, the screen moves onto the next word in the list. If not, the word stays the same until the student gets it correct. No matter the result, the attempt gets saved in the database.
- **Progress**  
  The wordlist data used for students. Take the existing progress screen and create a model based on the placeholder using progress_view_model.dart to store the variables and using the existing attempt.dart and word_practice_page.dart I created a repo for the attempts called attempts_repository.dart and within the actual progress.dart screen is just set up to call the variables and display their value
