from dataclasses import dataclass, asdict
from typing import Optional

@dataclass
class HardwareDevice:
    source: str
    device_id: str
    name: str
    vendor: str = "Unknown"
    device_class: str = "Other"
    driver_in_use: Optional[str] = None
    modalias: Optional[str] = None

    def to_dict(self):
        return asdict(self)

@dataclass
class Recommendation:
    device_id: str
    package: str
    reason: str
    confidence: str = "Review"
    source: str = "Orbit catalog"

    def to_dict(self):
        return asdict(self)
