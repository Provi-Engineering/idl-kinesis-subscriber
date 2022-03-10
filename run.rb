#!/usr/bin/ruby

require_relative "./environment"

class SampleRecordProcessor < Aws::KCLrb::V2::RecordProcessorBase
  def init_processor(initialize_input)
    @shard_id = initialize_input.shard_id
    @fh = File.open('messages.log','ab')
  end

  def process_records(process_records_input)
    last_seq = nil
    records = process_records_input.records
    records.each do |record|
      data = Base64.decode64(record['data'])
      @fh.puts record.inspect
      @fh.puts data.inspect
      @fh.flush
      last_seq = record['sequenceNumber']
    end

    checkpoint_helper(process_records_input.checkpointer, last_seq)
  end

  def checkpoint_helper(checkpointer, sequence_number = nil)
    begin
      checkpointer.checkpoint(sequence_number)
    rescue Aws::KCLrb::CheckpointError => e
      # Here, we simply retry once.
      # More sophisticated retry logic is recommended.
      checkpointer.checkpoint(sequence_number) if sequence_number
    end
  end

  def lease_lost(lease_lost_input)
    # lease was lost, cleanup
  end

  def shard_ended(shard_ended_input)
    # shard has ended, cleanup
  end

  def shutdown_requested(shutdown_requested_input)
    # shutdown has been requested
    @fh.close
  end
end

if __FILE__ == $0
  # Start the main processing loop
  record_processor = SampleRecordProcessor.new
  driver = Aws::KCLrb::KCLProcess.new(record_processor)
  driver.run
end