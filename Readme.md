### Java

You will need a Java runtime (you can use the openjdk package in homebrew)
```
brew install openjdk
```

Add JAVA_HOME to your .bashrc or similar file

```
export JAVA_HOME="/usr/local/Cellar/openjdk/17.0.2"
```

### Setup

Set the `applicationName` value in the `properties` file. A DynamoDB instance will be created based on this name to store the state of the workers. Use an AWS_PROFILE for the provi-development AWS account. You will need to be connected to the development VPN.

```
bundle install
AWS_PROFILE=provi-development properties_file=properties bundle exec rake run
```

The run task will download Java dependencies automatically. The task will launch the KCL app which will execute the process_records method in run.rb for each message received.


To publish a message into the stream

Run the console executable
```
AWS_PROFILE=provi-development ./console
```

Inside the Ruby console
```
kinesis = Aws::Kinesis::Client.new(
  region: 'us-east-2'
)

resp = kinesis.put_record({
  stream_name: "development-idl",
  data: { vendor_id: '22', type: 'front-line price', price: 22, sku: 'X123' }.to_json,
  partition_key: [Time.now.to_f, Process.pid].join("-"),
})
```