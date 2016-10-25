import sys

def main(argv):
	
	template = "master_finger: '{0}'"

	with open(sys.argv[1]) as f:
		 for line in f:
				if(line.startswith('master.pub: ')):
					print(template.format(line.replace('master.pub: ', '').strip()))
								
if __name__ == "__main__":
	main(sys.argv)
