ruby-error-logger
=================

Ruby error log processor. Has a writer and file rotator that processes errors in a pool of threads.

Install
=======

    gem 'ruby-error-logger',         git: 'git@github.com:pkaradimas/ruby-error-logger.git'


Writer
======

    # Set application logger
    require 'logger'
    PEL::CONFIG[:log] = Logger.new(STDOUT)

    # Set log file location, by default err.log
    PEL::CONFIG[:logfile] = 'path/to/err.log'

    writer = PEL::Writer.new
    writer.log "{json}"


Worker
======

    PEL::CONFIG[:logfile] = 'path/to/err.log'
    PEL::Rotator.new.run


Files get rotated after PEL::CONFIG[:rotate_size] or PEL::CONFIG[:rotate_time]

PEL::CONFIG[:read_queue_size] determines how many files are being 
processed at once.

Files are locked to sync on rotating.
Periodicaly if there are no timestamped files to work on
the err.log file will be moved to a worker.

                  W1
                  |
    err.log >> err.log.1234


Rotated files are err.log.{timestamp}, that way when one 
worker process removes a file, a new addition is added to the 
end and sorting is easier.


      |          W1                W2
                 |                 |
    err.log  err.log.1234      err.log.1235      err.log.1236


Some processing and W2 finishes file...


      |          W1                W2
                 |                 |
    err.log  err.log.1234      err.log.1236      err.log.1239

W2 moves to the next timestamped file.

As rotated files get added, the disk space is also considered(TODO) and
the oldest(NOTE up for discussion) files gets removed.



Limitations/Notes
=================

Current environment provides for only using the local filesytem which rules out
HDFS or a Mongodb cluster. Mongodb tends to retain files after deleting rows 
last I checked until compacting and indexes would become huge.

Each worker process should only handle files of limited size, or the rotated 
files could be split up and processed themselves.

