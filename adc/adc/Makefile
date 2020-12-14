DEPS = adc_sample.h iio_utils.h
OBJ = adc_sample.o iio_utils.o

%.o : %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

adc_sample: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

install: adc_sample
	mkdir -p $(WORKDIR)
	cp adc_sample $(WORKDIR)/

clean:
	rm -f *.o
	rm -f adc_sample
