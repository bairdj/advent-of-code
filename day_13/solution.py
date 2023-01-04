from typing import List, Union, Optional
import os

class Packet:
    def __init__(self, contents: List[Union[List, int]]):
        self.contents = contents

    @staticmethod
    def compare_items(left: Union[List, int], right: Union[List, int]) -> Optional[bool]:
        if isinstance(left, int) and isinstance(right, int):
            if left == right:
                return None
            return left < right
        if isinstance(left, list) and isinstance(right, list):
            i = 0
            while True:
                if i >= len(left) and i < len(right):
                    return True
                if i < len(left) and i >= len(right):
                    return False
                if i >= len(left) and i >= len(right):
                    return None
                left_item = left[i]
                right_item = right[i]
                result = Packet.compare_items(left_item, right_item)
                if result is not None:
                    return result
                i += 1
        if isinstance(left, int) and isinstance(right, list):
            return Packet.compare_items([left], right)
        if isinstance(left, list) and isinstance(right, int):
            return Packet.compare_items(left, [right])

class PacketPair:
    def __init__(self, packet_1: Packet, packet_2: Packet):
        self.packet_1 = packet_1
        self.packet_2 = packet_2

    def check_packet_order(self) -> bool:
        return Packet.compare_items(self.packet_1.contents, self.packet_2.contents)



def parse_packet(s: str) -> Packet:
    # This is bad but otherwise need to write a full parser
    return Packet(eval(s))

        

input_path = os.path.join(os.path.dirname(__file__), 'input.txt')

packet_pairs = []

with open(input_path, 'r') as f:
    packet_1 = None
    for packet in f:
        if packet == '\n':
            continue
        if packet_1 is None:
            packet_1 = parse_packet(packet)
        else:
            packet_2 = parse_packet(packet)
            packet_pair = PacketPair(packet_1, packet_2)
            packet_pairs.append(packet_pair)
            packet_1 = None


# Get the 1-indexed indices of packets in the right order
packet_order = []
for i, packet_pair in enumerate(packet_pairs):
    if packet_pair.check_packet_order():
        packet_order.append(i + 1)

print(f"Sum of correct packet order indices: {sum(packet_order)}")