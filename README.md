## Welcome to Achint't slot management system
```text
This is a sample project wherein a user can find relevant interview slots basis interviewers availability.
```

### Assumptions
```text
1. To book a slot, User (Interviewee/Student) will always be logged in. Therefore user_id will always be availabile.
2. There is a system via which interviewers are able to add their available slots. Managing slots is out of scope.
3. The student cannot schedule more interviews if both of the last 2 completed interviews have grade less than or equal to 1.
4. The student cannot schedule another interview during an on-going interview.
5. API security features like rate-limits, authentication, etc. have to be handled separately and not part of this implementation.
```

### System Requirements
- Ruby 2.6.3
- Rails 5.2.3
- MySQL

### To setup the solution, use the following command:
```shell
bundle install
```

### To run rails console:
```
rails console
```

### To run rails server:
```
rails server
```

### To run tests, use the following command:
```shell
rspec spec
```
