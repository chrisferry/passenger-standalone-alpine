def main
	versions = {
		old: ['2.1.9'],
		stable: '2.3.1'
	}

	all_versions = versions[:old].dup << versions[:stable] # << versions[:preview]

	threads = []

	puts "Generating keys.."

	generate_keys

	puts "Generated keys."

	puts "Building packages.."

	all_versions.each do |version|
		# Build packages
		threads << Thread.new do
			build_package(version)
			# Build container with package added
			# Tag container
		end
	end

	threads.each(&:join)
	puts "\nDone.."
end

def generate_keys
	root_dir = File.expand_path(File.dirname(__FILE__))
	keys = "#{root_dir}/keys"

	return unless `ls #{keys}`.empty?

	puts "No keys present."

	output = `docker run \
	  --rm -it \
	  --entrypoint abuild-keygen \
	  -v #{keys}:/home/builder/.abuild/ \
	  -e PACKAGER="Tinco Andringa<tinco@phusion.nl>" \
	  andyshinn/alpine-abuild:v2 -n`
	raise "Generate keys failed:\n#{output}" unless $?.success?

	puts "Generate keys output: #{output}"
	puts `mv #{keys}/*.pub #{keys}/phusion.rsa.pub`
	puts `mv #{keys}/*.rsa #{keys}/phusion.id_rsa`
end

def build_package(name)
	root_dir = File.expand_path(File.dirname(__FILE__))
	package = "#{root_dir}/#{name}"
	repository = "#{root_dir}/build-cache/packages"
	keys = "#{root_dir}/keys"
	
	output = `docker run -it \
	    -e PACKAGER_PRIVKEY="/phusion.id_rsa" \
	    -v "#{package}:/home/builder/package" \
	    -v "#{repository}:/packages" \
	    -v "#{keys}/phusion.rsa.pub:/etc/apk/keys/phusion.rsa.pub" \
	    -v "#{keys}/phusion.id_rsa:/phusion.id_rsa" \
	    andyshinn/alpine-abuild:v2`
	raise "Build package #{name} failed:\n#{output}" unless $?.success?
end

main
