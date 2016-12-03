# RESTful Natural Language Parse Service

A RESTful service that service NLP parsing requests.  This makes
the [NLP parsing project](https://github.com/plandes/clj-nlp-parse) available
as a [REST service](https://en.wikipedia.org/wiki/Representational_state_transfer).


## Documentation

Additional [documentation](https://plandes.github.io/clj-nlp-serv/codox/index.html).


## Usage

You can use this as a command line program to generate a prettyprint parse tree
of an utterance.  However, you have to let it know where the
Stanford CoreNLP libraries are configured (see the
[NLP parse project setup docs](https://github.com/plandes/clj-nlp-parse#setup)
for more information.

To create the command line utility, do the following:

- Install [Leiningen](http://leiningen.org) (this is just a script)
- Install [GNU make](https://www.gnu.org/software/make/)
- Install [Git](https://git-scm.com)
- Download the source:
```bash
$ git clone https://github.com/clj-nlp-parse
```
- Follow the directions in [build section](#building)
- Edit and uncomment the `makefile` to set the `ZMODEL` variable, which should
  be set to a directory having the stanford POS model(s) in `standford/pos`.
- Build the distribution binaries:
```bash
$ make dist
```
If everything goes well and you are lucky a new folder should show up on your
desktop with everything you need to run it.  To do that:
```bash
$ cd ~/Desktop/parse/bin
$ ./nlparse parse -u 'I am Paul Landes'
```

Now start the RESTful service, on say, port 9000 (defaults to 8080):
```bash
$ ./nlparse service -p 9000'
```

Use a web client to test the service using the *pretty print* option:
```bash
$ wget -q -O - 'http://localhost:9000/parse?utterance=My+name+is+Paul+Landes&pretty=true'
```

The output:
```json
{"text":"My name is Paul Landes",
 "mentions":
 [{"entity-type":"PERSON",
   "token-range":[3, 5],
   "ner-tag":"PERSON",
   "sent-index":0,
   "char-range":[11, 22],
   "text":"Paul Landes"}],
 "tok-re-mentions":[],
 "coref":
 [{"id":1,
   "mention":
   [{"sent-index":1,
     "token-range":[4, 6],
     "head-index":5,
     "gender":"MALE",
     "animacy":"ANIMATE",
     "type":"PROPER",
     "number":"SINGULAR"}]},
```

**Note:** I will make the distribution binaries available on request.


### Usage Help

For convenience, here's the usage docs you get when invoking with no
parameters:
```sql
$ nlparse
repl	start a repl either on the command line or headless with -h
  -h, --headless            start an nREPL server
  -p, --port NUMBER  12345  the port bind for the repl server

 parse	parse an English utterance
  -l, --level LOG LEVEL  INFO  Log level to set in the Log4J2 system.
  -u, --utterance TEXT         The utterance to parse
  -p, --pretty                 Pretty print the JSON string

 service	start the agent parse website and service
  -p, --port PORT  8080  the port bind for web site/service

 version	Get the version of the application.
  -g, --gitref
```


## Building

All [leiningen](http://leiningen.org) tasks will work in this project.  For
additional build functionality (like building the command line application and
git tag convenience utility functionality) clone the
[Clojure build repo](https://github.com/plandes/clj-zenbuild) in the same
(parent of this file) directory as this project:
```bash
   cd ..
   git clone https://github.com/plandes/clj-zenbuild
```


## License

Copyright © 2016, 2017 Paul Landes

Apache License version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
