"""Script"""

import argparse
import datetime
import logging
import pathlib
import sys
import traceback

import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


def main() -> None:
    return None


if __name__ == "__main__":
    try:
        main()
    except Exception:  # pylint: disable=W0718
        logging.error(traceback.format_exc())

        local = {}
        for k, v in sys.exc_info()[2].tb_next.tb_frame.f_locals.items():  # type: ignore
            if len(str(v)) > 500:
                local[k] = str(v)[:500]
            else:
                local[k] = v

        logging.error("Local variables: %s", local)
