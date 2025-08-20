from dataclasses import dataclass

from nexadata.value import get_env


@dataclass(frozen=True)
class ConstType: ...


@dataclass(frozen=True)
class EnvType:
    PATH_PREFIX = get_env("PATH_PREFIX", str)


Const = ConstType()
Env = EnvType()
