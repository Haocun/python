#
# This is the makefile for the python related programs
#
# Make sure you have defined $PYTHON as this directory first
# then type 
# 	make [GIT=False] install
#
# if this fails, consult https://github.com/agnwinds/python/wiki/Installing-Python
# for manual install.

CFITSIO = $(PYTHON)/software/cfitsio3040
CMAKE = mpicc
GSL = $(PYTHON)/software/gsl-1.15
GIT = True
LIBS = True


ifeq (True, $(GIT))
	CLONE_DATA =  mkdir $(PYTHON)/data; cd $(PYTHON)/data; git clone https://github.com/agnwinds/python.git -b data .
	CLONE_RELEASE = mkdir $(PYTHON)/progs; cd $(PYTHON)/progs; git clone https://github.com/agnwinds/python.git; cd python; make CC=$(CMAKE) python; make CC=$(CMAKE) py_wind
	PRINT_CLONE = 'Cloning Git Release'
else
	CLONE_DATA = 
	CLONE_RELEASE = 
	PRINT_CLONE = 'No git installed- have to obtain release and data manually from releases page on github. Exiting.'
endif

ifeq (True, $(LIBS))
	INSTALL_CFITSIO = cd $(CFITSIO); ./configure; make; mv libcfitsio.a ../../lib; make clean
	INSTALL_GSL = cd $(GSL); ./configure --disable-shared --prefix=$(GSL); make; make check 2>&1; make install; make clean; 
	MOVE_GSL = mkdir $(PYTHON)/include/gsl/; mv $(GSL)/include/gsl* $(PYTHON)/include/gsl/; mv $(GSL)/lib/* $(PYTHON)/include/gsl/;
else
	INSTALL_CFITSIO = 
	INSTALL_GSL = 
	MOVE_GSL =
endif

install:
	@echo 'Installing Python. the radiative transfer code'
	@echo 'Installing in directory '$(PYTHON)
	# First make cfitsio library
	@echo 'Installing CFITSIO library...'
	$(INSTALL_CFITSIO)
	
	# Then make GSL library
	@echo 'Installing GSL library...'
	$(INSTALL_GSL)
	$(MOVE_GSL)

	# get atomic data from git
	@echo 'Installing Atomic data'
	$(CLONE_DATA)

	
	#finally, make the latest release
	@echo 'Making latest release...'
	@echo $(PRINT_CLONE)
	$(CLONE_RELEASE)

	@echo 'Copying Setup_Py_dir to scripts directory'
	cp $(PYTHON)/py_progs/setup_scripts/Setup_Py_Dir $(PYTHON)/bin

	@echo 'all done'

clean: 
	rm -f *.o *~
	cd $(CFITSIO); make clean
	cd $(GSL); make clean 
	cd $(PYTHON)/progs/python; make clean
