**NOTES**

There are a bunch of things that are problematic and incomplete with this solution as it stands. In a real-world scenario, some of the improvements and enhancements, I would like to implement are:

- All business logic is in a single class. It should be separated out into smaller, tighter classes that do one thing only. Specifically, I would create a parser helper class to house all parsing logic. I would also create a validator class to isolate validations. This should result in smaller classes following the single-responsibility principle.
- Correspondingly, all automated tests are lumped in a single class. They would be broken into separate test classes one for each class under test.
- More targeted unit tests should be written to thoroughly exercize the logic.
- Some methods should be made private as they should not be part of the public API. Specifically, the checksum calculation should not be exposed to client applications.
- Integration tests using a real file system can be helpful and is recommended for sanity testing. This is especially true for any nightly tests and for testing any reporting that needs to happen for User Story #3
- Fuzzy Matches: User Story #4 talks about attempting to guess digits of an account number if there is a single missed character per digit. Since I have implemented the solution using arrays as opposed to straight string comparisons, we now have a way to compare each coordinate in the digits matrix with our predefined,constant digit maps and pinpoint exactly where they differ. It would be easy to see how many digit maps differ by exactly one character. For cases where only one such match exists, we can safely guess the correct digit. For all other cases, the status can be reported as 'AMB'