## Notebook Reading
Never use `python3 -c` to read or validate .ipynb files. Instead, use `cat` or `jq` to inspect them:
- `cat notebook.ipynb` to read raw content
- `jq '.cells[].source' notebook.ipynb` to extract cell sources
- `jq '.cells[] | select(.cell_type=="code") | .source' notebook.ipynb` for code cells only
