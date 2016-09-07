ROOT_DIR = File.expand_path(File.dirname(__FILE__))
IMAGE_NAME = "phusion/ruby-alpine"

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

	names = []

	all_versions.each do |version|
		# Build packages
		threads << Thread.new do
			puts "Going to build packages for #{version}"
			build_packages(version)
			puts "--------------------"
			puts "Going to build container for #{version}"
			names << build_container(version)
			puts "--------------------"
		end
	end

	threads.each(&:join)
	puts "\nDone.."

	system 'reset'
	
	names.each {|n| puts "Built image: #{n}"}
end

def generate_keys
	keys = "#{ROOT_DIR}/keys"

	return unless `ls #{keys}`.empty?

	puts "No keys present."

	output = system %Q{ docker run \
	  --rm -it \
	  --entrypoint abuild-keygen \
	  -v #{keys}:/home/builder/.abuild/ \
	  -e PACKAGER="Tinco Andringa<tinco@phusion.nl>" \
	  andyshinn/alpine-abuild:v2 -n \
    }
	raise "Generate keys failed:\n#{output}" unless $?.success?

	puts "Generate keys output: #{output}"
	system %Q{ mv #{keys}/*.pub #{keys}/phusion.rsa.pub }
	system %Q{ mv #{keys}/*.rsa #{keys}/phusion.rsa.priv }
	system %Q{ echo "Elevating priviliges to fix permissions of key files."; sudo chmod -R a+r #{keys} }
end

def build_container(version)
	name = "#{IMAGE_NAME}:#{version}-slim"
	context = "#{ROOT_DIR}/context/#{version}"
	repository = "#{ROOT_DIR}/build-cache/packages/#{version}/*"

	system "mkdir -p #{context}"
	system "cp -r #{repository} #{context}/packages/"
	system "cp #{ROOT_DIR}/context/shared/* #{context}/"

	system "docker build -t #{name} --build-arg RUBY_VERSION=#{version} #{context}"
	name
end

def build_packages(version)
	package = "#{ROOT_DIR}/#{version}"
	repository = "#{ROOT_DIR}/build-cache/packages/#{version}"

	system %Q{ mkdir -p -m 777 #{repository}}
	
	# We need to have a git repository with a tag in the package directory for some reason.
	system %Q{ cd #{package}; git init; git add .; git commit -a -m "init"; git tag -m "init" init }

	keys = "#{ROOT_DIR}/keys"
	
	output = system %Q{ docker run -it \
		-e PACKAGER="Tinco Andringa<tinco@phusion.nl>" \
	    -e PACKAGER_PRIVKEY="/phusion.rsa.priv" \
	    -v "#{package}:/home/builder/package" \
	    -v "#{repository}:/packages" \
	    -v "#{keys}/phusion.rsa.pub:/etc/apk/keys/phusion.rsa.pub" \
	    -v "#{keys}/phusion.rsa.priv:/phusion.rsa.priv" \
	    phusion/abuild \
	}
	# raise "Build package #{version} failed:\n#{output}" unless $?.success?

	# Clean up the git repository we made for abuilder
	system %Q{ rm -rf #{package}/.git }
end

main
