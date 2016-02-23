
FC=gfortran

FILES := $(shell echo *.f{tn,90})
OBJECTS := $(patsubst %ftn, %o, $(patsubst %f90, %o, $(FILES)))
INCLUDE := -I$(shell nf-config --includedir)

FCFLAGS := -ffixed-line-length-132
LIBS := $(shell nf-config --flibs)

%.o: %.ftn
	$(FC) -c $(FCFLAGS) $(INCLUDE) $< -o $@

%.o: %.f90
	$(FC) -c $(FCFLAGS) $(INCLUDE) $< -o $@


all: $(OBJECTS)
	$(FC) $(LIBS) $(OBJECTS) -o test.exe

clean:
	rm -f *.o *.exe
