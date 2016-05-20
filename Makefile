all: install.sh

install.sh: make_installer.py templates/basic.sh
	python make_installer.py \
		--template=templates/basic.sh \
		utilities \
		https://github.com/datawire/utilities/archive/master.zip \
		utilities \
		> install.sh

clean:
	rm -f install.sh

clobber: clean
