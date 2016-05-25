all: install.sh

install.sh: checkEnv pip make_installer.py templates/basic.sh
	python make_installer.py \
		--template=templates/basic.sh \
		utilities \
		https://github.com/datawire/utilities/archive/master.zip \
		utilities \
		> install.sh

checkEnv:
	@if [ -z "$$VIRTUAL_ENV" ]; then echo "You must be in a venv for this"; false; fi

pip: checkEnv
	pip install -q -r requirements.txt	# for dev

clean:
	rm -f install.sh

clobber: clean
