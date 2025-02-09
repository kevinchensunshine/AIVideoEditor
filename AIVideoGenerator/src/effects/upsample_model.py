import torch
import torch.nn as nn
import torch.nn.functional as F 

class Upsample(nn.Module):
    def __init__(self):
        super().__init__()
    
    def forward(self, x):
        x = F.interpolate(x, scale_factor=2, mode='bilinear', align_corners=False)
        return x 

upsample_model = Upsample()

example_image = torch.randint(256, (1, 1, 256, 256)).float()
trace = torch.jit.trace(upsample_model.forward, example_image, check_trace=True)

torch.jit.save(trace, "./artifacts/torch/upsample_model_trace.pt")