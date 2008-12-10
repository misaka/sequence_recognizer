require 'set'

module SequenceRecognizer
  def self.included(base)
    base.extend(Methods)
    base.class_eval do
      include Methods
    end
  end

  module Methods
    def extract_sequences_from(array_of_shortcodes, shortcode_length = 5)
      shortcodes_by_mask = {}

      # Organise the shortcodes by mask, so that this:
      #
      #   [ 111, 121, 131 ]
      #
      # is turned into this:
      #
      #   { '*11' => [ 111 ],
      #     '1*1' => [ 111, 121, 131 ],
      #     '11*' => [ 111 ],
      #     '*21' => [ 121 ],
      #     '*31' => [ 131 ],
      #     '12*' => [ 121 ],
      #     '13*' => [ 131 ] }
      #
      # in the variable shortcodes_by_mask

      array_of_shortcodes.each do |shortcode|
        shortcode_length.times do |index|

          # Clone the shortcode since we want to create a new mask each
          # iteration, we would end uf with '***' if we didn't do this.
          mask = shortcode.to_s.clone

          mask[index] = '*'
          shortcodes_by_mask[mask] ||= []
          shortcodes_by_mask[mask] << shortcode.to_i
        end
      end

      sequences = []

      # Now go through all of our masks and try to find the number of
      # sequences per series.
      shortcodes_by_mask.each do |mask,series|

        # increment is the number we'll add to the shortcode to see if it is
        # sequential.
        increment = 10 ** ( shortcode_length - mask.index( '*' ) - 1 )

        while !series.empty? do
          # next_sequence will just grab the next sequence and return it,
          sequence = next_sequence( series, increment )
          sequences << sequence.map { |sc| sc.to_s } if sequence.length > 2
        end
      end

      sequences
    end

    def next_sequence( series, increment )
      sequence = []

      sequence << series.shift
      while series[0] && sequence[-1] + increment == series[0] do
        sequence << series.shift
      end

      sequence
    end
  end
end
