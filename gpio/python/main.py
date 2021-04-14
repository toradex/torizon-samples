#!python
import time
import argparse
import gpiod

def list_chips_and_pins():
    for chip in gpiod.chip_iter():
        print(f"{chip.label}\t{chip.name}")

        for line in chip.get_all_lines():
            print(f"\t{line.offset}\t{line.name}\t{line.consumer}")

def set_line_state(line,state):
    gpioline = gpiod.find_line(line)

    if gpioline is None:
        print("Invalid line name.")
        return

    config = gpiod.line_request()

    config.consumer="GPIO sample"
    config.request_type=gpiod.line_request.DIRECTION_OUTPUT

    gpioline.request(config, 1 if state else 0)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Python-GPIO sample for Torizon")

    parser.add_argument("line",help="line name",nargs="?")

    args = parser.parse_args()

    if not "line" in args or args.line is None:
        list_chips_and_pins()
    else:
        while True:
            set_line_state(args.line,True)
            time.sleep(1)
            set_line_state(args.line,False)
            time.sleep(1)
        