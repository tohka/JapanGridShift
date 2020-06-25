#!/usr/bin/ruby


GRS80_a  = 6378137.0
GRS80_F  = 298.257222101
GRS80_b  = GRS80_a  * (1.0 - 1.0 / GRS80_F )
BESSEL_a = 6377397.155 
BESSEL_F = 299.1528128
BESSEL_b = BESSEL_a * (1.0 - 1.0 / BESSEL_F)

def main
	# Tokyo Datum to JGD2000
	convert('TKY2JGD.par', 'tky2jgd.gsb', {
			'VERSION'  => '2.1.2',
			'SYSTEM_F' => 'Tokyo',
			'MAJOR_F'  => BESSEL_a,
			'MINOR_F'  => BESSEL_b,
			'SYSTEM_T' => 'JGD2000',
			'MAJOR_T'  => GRS80_a,
			'MINOR_T'  => GRS80_b,
			'CREATED'  => '20010301',
			'UPDATED'  => '20031007'
	})

	# JGD2000 to JGD2011
	convert('touhokutaiheiyouoki2011.par', 'touhokutaiheiyouoki2011.gsb', {
			'VERSION'  => '4.0.0',
			'SYSTEM_F' => 'JGD2000',
			'MAJOR_F'  => GRS80_a,
			'MINOR_F'  => GRS80_b,
			'SYSTEM_T' => 'JGD2011',
			'MAJOR_T'  => GRS80_a,
			'MINOR_T'  => GRS80_b,
			'CREATED'  => '20111031',
			'UPDATED'  => '20171205'
	})
end

def convert(par_file, gsb_file, opts)
	gs = JapanGridShift.new(par_file)
	gs.to_gsb(gsb_file, opts)
end


class JapanGridShift
	def initialize(par_file)
		@file = par_file
		@data = {}
		@bbox = {:s => 1e8, :n => -1e8, :w => 1e8, :e => -1e8}

		open(@file, 'r') do |io|
			true until io.gets[0, 8] == 'MeshCode'

			io.each do |line|
				code, db, dl = line.strip.split(/\s+/)

				# Japanese MeshCode to lat/lng [arcsec]
				lat = code[0, 2].to_i * 2400 +
						code[4].to_i * 300 + code[6].to_i * 30
				lng = (100 + code[2, 2].to_i) * 3600 +
						code[5].to_i * 450 + code[7].to_i * 45
				@data[code] = [db, dl]
				@bbox[:s] = lat if @bbox[:s] > lat
				@bbox[:n] = lat if @bbox[:n] < lat
				@bbox[:w] = lng if @bbox[:w] > lng
				@bbox[:e] = lng if @bbox[:e] < lng
			end
			@rows = ((@bbox[:n] - @bbox[:s]) / 30.0).round + 1
			@cols = ((@bbox[:e] - @bbox[:w]) / 45.0).round + 1
		end
	end

	def each
		# south-east -> south-west -> ... -> north-west
		@bbox[:s].step(@bbox[:n], 30) do |lat|
			@bbox[:e].step(@bbox[:w], -45) do |lng|
				# lat/lng [arcsec] to Japanese MeshCode
				code = '%02d%02d%d%d%d%d' % [
						lat / 2400,
						lng / 3600 - 100,
						(lat % 2400) / 300,
						(lng % 3600) / 450,
						(lat % 300) / 30,
						(lng % 450) / 45
				]
				if @data.has_key?(code)
					d = @data[code]
					yield [d[0].to_f, -1 * d[1].to_f, 0.0, 0.0]
				else
					yield [0.0, 0.0, 0.0, 0.0]
				end
			end
		end
	end

	def to_gsb(file, opts)
		open(file, 'wb') do |io|
			io.print char8('NUM_OREC') + int4(11) + int4()
			io.print char8('NUM_SREC') + int4(11) + int4()
			io.print char8('NUM_FILE') + int4( 1) + int4()
			io.print char8('GS_TYPE ') + char8('SECONDS ')
			io.print char8('VERSION ') + char8(opts['VERSION'])
			io.print char8('SYSTEM_F') + char8(opts['SYSTEM_F'])
			io.print char8('SYSTEM_T') + char8(opts['SYSTEM_T'])
			io.print char8('MAJOR_F ') + real8(opts['MAJOR_F'])
			io.print char8('MINOR_F ') + real8(opts['MINOR_F'])
			io.print char8('MAJOR_T ') + real8(opts['MAJOR_T'])
			io.print char8('MINOR_T ') + real8(opts['MINOR_T'])

			io.print char8('SUB_NAME') + char8('NONE    ')
			io.print char8('PARENT  ') + char8('NONE    ')
			io.print char8('CREATED ') + char8(opts['CREATED'])
			io.print char8('UPDATED ') + char8(opts['UPDATED'])
			io.print char8('S_LAT   ') + real8(@bbox[:s])
			io.print char8('N_LAT   ') + real8(@bbox[:n])
			io.print char8('E_LONG  ') + real8(@bbox[:e] * -1)
			io.print char8('W_LONG  ') + real8(@bbox[:w] * -1)
			io.print char8('LAT_INC ') + real8(30.0)
			io.print char8('LONG_INC') + real8(45.0)
			io.print char8('GS_COUNT') + int4(size) + int4()

			each do |record|
				io.print real4(record[0]) + real4(record[1]) +
						real4(record[2]) + real4(record[3])
			end

			io.print char8('END     ') + real8(0.0)
		end
	end
	def data(k); @data[k]; end
	def bbox; @bbox; end
	def rows; @rows; end
	def cols; @cols; end
	def size; @rows * @cols; end

	def char8(v = '' ); (v.strip + '        ')[0, 8]; end
	def int4 (v = 0  ); [v].pack('V'); end
	def real4(v = 0.0); [v].pack('e'); end
	def real8(v = 0.0); [v].pack('E'); end
end

main
