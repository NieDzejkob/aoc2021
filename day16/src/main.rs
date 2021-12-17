use std::error::Error;
use nom::{IResult, Finish};
use nom::error::{Error as ParseError, ErrorKind};
use nom::combinator::{all_consuming, map};
use nom::multi::{many0, length_value, length_count};
use bitvec::prelude::*;
use bitvec::mem::BitMemory;
use nom_bitvec::BSlice;
use itertools::Itertools;

type Bits<'a> = BSlice<'a, Msb0, u8>;

#[derive(Clone, Debug, PartialEq)]
struct Packet {
    version: u8,
    ty: u8,
    data: PacketData,
}

impl Packet {
    fn version_sum(&self) -> u64 {
        self.data.into_iter().map(Packet::version_sum).sum::<u64>() + self.version as u64
    }

    fn fold_values<B>(&self, start: B, f: impl FnMut(B, u64) -> B) -> Option<B> {
        self.data.into_iter().map(Packet::evaluate).fold_options(start, f)
    }

    fn pair(&self) -> Option<(u64, u64)> {
        match self.data {
            Subpackets(ref v) => match v.as_slice() {
                [a, b] => Some((a.evaluate()?, b.evaluate()?)),
                _ => None,
            }
            _ => None,
        }
    }

    fn evaluate(&self) -> Option<u64> {
        match self.ty {
            0 => self.fold_values(0, |a, b| a + b),
            1 => self.fold_values(1, |a, b| a * b),
            2 => self.fold_values(u64::MAX, |a, b| a.min(b)),
            3 => self.fold_values(0, |a, b| a.max(b)),
            4 => match self.data {
                Literal(v) => Some(v),
                Subpackets(_) => None,
            }
            5 => self.pair().map(|(a, b)| (a > b) as u64),
            6 => self.pair().map(|(a, b)| (a < b) as u64),
            7 => self.pair().map(|(a, b)| (a == b) as u64),
            _ => None,
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
enum PacketData {
    Literal(u64),
    Subpackets(Vec<Packet>),
}

impl<'a> IntoIterator for &'a PacketData {
    type Item = &'a Packet;
    type IntoIter = std::slice::Iter<'a, Packet>;

    fn into_iter(self) -> Self::IntoIter {
        match self {
            Literal(_) => [].iter(),
            Subpackets(v) => v.iter(),
        }
    }
}

use PacketData::*;

fn take<M: BitMemory>(n: usize) -> impl Fn(Bits) -> IResult<Bits, M> {
    move |input| {
        if n <= input.0.len() {
            let v = input.0[0..n].load_be();
            Ok((BSlice(&input.0[n..]), v))
        } else {
            Err(nom::Err::Error(ParseError::new(input, ErrorKind::Eof)))
        }
    }
}

fn literal(input: Bits, rest: u64) -> IResult<Bits, u64> {
    let (input, last): (_, u8) = take(1_usize)(input)?;
    let (input, part): (_, u64) = take(4_usize)(input)?;
    let v = (rest << 4) | part;
    if last == 0 {
        Ok((input, v))
    } else {
        literal(input, v)
    }
}

fn subpackets(input: Bits) -> IResult<Bits, Vec<Packet>> {
    let (input, variant) = take(1_usize)(input)?;
    match variant {
        0_u8 => length_value(take::<usize>(15_usize), all_consuming(many0(packet)))(input),
        1_u8 => length_count(take::<usize>(11_usize), packet)(input),
        _ => unreachable!()
    }
}

fn packet(input: Bits) -> IResult<Bits, Packet> {
    let (input, version) = take(3_usize)(input)?;
    let (input, ty) = take(3_usize)(input)?;
    let (input, data) = match ty {
        4 => map(|input| literal(input, 0), Literal)(input)?,
        _ => map(subpackets, Subpackets)(input)?,
    };

    Ok((input, Packet {
        version,
        ty,
        data,
    }))
}

fn parse_hex(s: &str) -> Result<Packet, Box<dyn Error>> {
    let bytes = hex::decode(s)?;
    let parsed = packet(BSlice(bytes.view_bits()));
    let packet = parsed.finish().map_err(|_| ":(")?.1;
    Ok(packet)
}

fn main() {
    let input = "005173980232D7F50C740109F3B9F3F0005425D36565F202012CAC0170004262EC658B0200FC3A8AB0EA5FF331201507003710004262243F8F600086C378B7152529CB4981400B202D04C00C0028048095070038C00B50028C00C50030805D3700240049210021C00810038400A400688C00C3003E605A4A19A62D3E741480261B00464C9E6A5DF3A455999C2430E0054FCBE7260084F4B37B2D60034325DE114B66A3A4012E4FFC62801069839983820061A60EE7526781E513C8050D00042E34C24898000844608F70E840198DD152262801D382460164D9BCE14CC20C179F17200812785261CE484E5D85801A59FDA64976DB504008665EB65E97C52DCAA82803B1264604D342040109E802B09E13CBC22B040154CBE53F8015796D8A4B6C50C01787B800974B413A5990400B8CA6008CE22D003992F9A2BCD421F2C9CA889802506B40159FEE0065C8A6FCF66004C695008E6F7D1693BDAEAD2993A9FEE790B62872001F54A0AC7F9B2C959535EFD4426E98CC864801029F0D935B3005E64CA8012F9AD9ACB84CC67BDBF7DF4A70086739D648BF396BFF603377389587C62211006470B68021895FCFBC249BCDF2C8200C1803D1F21DC273007E3A4148CA4008746F8630D840219B9B7C9DFFD2C9A8478CD3F9A4974401A99D65BA0BC716007FA7BFE8B6C933C8BD4A139005B1E00AC9760A73BA229A87520C017E007C679824EDC95B732C9FB04B007873BCCC94E789A18C8E399841627F6CF3C50A0174A6676199ABDA5F4F92E752E63C911ACC01793A6FB2B84D0020526FD26F6402334F935802200087C3D8DD0E0401A8CF0A23A100A0B294CCF671E00A0002110823D4231007A0D4198EC40181E802924D3272BE70BD3D4C8A100A613B6AFB7481668024200D4188C108C401D89716A080";
    let packet = parse_hex(input).unwrap();
    println!("{} {}", packet.version_sum(), packet.evaluate().unwrap());
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lit(version: u8, value: u64) -> Packet {
        Packet {
            version,
            ty: 4,
            data: Literal(value),
        }
    }

    #[test]
    fn example1() {
        assert_eq!(parse_hex("D2FE28").unwrap(), lit(6, 2021));
    }

    #[test]
    fn example2() {
        assert_eq!(parse_hex("38006F45291200").unwrap(),
        Packet {
            version: 1,
            ty: 6,
            data: Subpackets(vec![lit(6, 10), lit(2, 20)]),
        });
    }

    #[test]
    fn example3() {
        assert_eq!(parse_hex("EE00D40C823060").unwrap(),
        Packet {
            version: 7,
            ty: 3,
            data: Subpackets(vec![lit(2, 1), lit(4, 2), lit(1, 3)]),
        });
    }

    #[test]
    fn sums() {
        assert_eq!(parse_hex("8A004A801A8002F478").unwrap().version_sum(), 16);
        assert_eq!(parse_hex("620080001611562C8802118E34").unwrap().version_sum(), 12);
        assert_eq!(parse_hex("C0015000016115A2E0802F182340").unwrap().version_sum(), 23);
        assert_eq!(parse_hex("A0016C880162017C3686B18A3D4780").unwrap().version_sum(), 31);
    }

    #[test]
    fn values() {
        assert_eq!(parse_hex("C200B40A82").unwrap().evaluate().unwrap(), 3);
        assert_eq!(parse_hex("04005AC33890").unwrap().evaluate().unwrap(), 54);
        assert_eq!(parse_hex("880086C3E88112").unwrap().evaluate().unwrap(), 7);
        assert_eq!(parse_hex("CE00C43D881120").unwrap().evaluate().unwrap(), 9);
        assert_eq!(parse_hex("D8005AC2A8F0").unwrap().evaluate().unwrap(), 1);
        assert_eq!(parse_hex("F600BC2D8F").unwrap().evaluate().unwrap(), 0);
        assert_eq!(parse_hex("9C005AC2F8F0").unwrap().evaluate().unwrap(), 0);
        assert_eq!(parse_hex("9C0141080250320F1802104A08").unwrap().evaluate().unwrap(), 1);
    }
}
