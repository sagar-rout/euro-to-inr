
I know this application does not make much sense, I just want to learn something. During my learning 
time, I didn't find interesting topic.

# Euro to inr
Convert Euro to INR and send notification if it crosses a defined threshold.


## Deployment
- Create zip of node_modules, src/ and file which has lambda function all at root level of zip.
```bash
    zip -r node_modules src index.js
```

## Terraform
Terraform will setup lambda and event.

## Testing
- Use https://www.npmjs.com/package/lambda-local for testing