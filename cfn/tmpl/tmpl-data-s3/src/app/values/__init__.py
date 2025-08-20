from dataclasses import dataclass


@dataclass(frozen=True)
class ConstType: ...


@dataclass(frozen=True)
class EnvType: ...


Const = ConstType()
Env = EnvType()
