## Generate inputs

```python
import gemini3d.model
import sys
from pathlib import Path

cfgdir = "~/gemini/gemini-examples/init/CEDAR2024/ESF_periodic_lowres"

fpath = Path(cfgdir).expanduser()

sys.path.append(str(fpath))

gemini3d.model.setup(fpath / "config.nml", "~/gemini/ESF_periodic")
```
