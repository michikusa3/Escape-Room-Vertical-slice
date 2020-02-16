﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

/// <summary>
/// Ubh paint shot.
/// </summary>
[AddComponentMenu("UniBulletHell/Shot Pattern/Paint Shot")]
public class UbhWayPaintShot : UbhBaseShot
{
    private static readonly string[] SPLIT_VAL = { "\n", "\r", "\r\n" };

    [Header("===== PaintShot Settings =====")]
    // "Set a paint data text file. (ex.[UniBulletHell] > [Example] > [PaintShotData] in Project view)"
    // "BulletNum is ignored."
    [FormerlySerializedAs("_PaintDataText")]
    public TextAsset m_paintDataText;
    // "Set a center angle of shot. (0 to 360) (center of first line)"
    [Range(0f, 360f), FormerlySerializedAs("_PaintCenterAngle")]
    public float m_paintCenterAngle = 180f;
    // "Set a angle between bullet and next bullet. (0 to 360)"
    [Range(0f, 360f), FormerlySerializedAs("_BetweenAngle")]
    public float m_betweenAngle = 3f;
    // "Set a delay time between shot and next line shot. (sec)"
    [FormerlySerializedAs("_NextLineDelay")]
    public float m_nextLineDelay = 0.1f;
    [FormerlySerializedAs("_WayNum")]
    public int m_wayNum;
        // "Set a center angle of shot. (0 to 360)"
    [Range(0f, 360f), FormerlySerializedAs("_CenterAngle")]
    public float m_centerAngle = 180f;


    private int m_nowIndex;
    private float m_delayTimer;

    private List<List<int>> m_paintData;
    private float m_paintStartAngle;

    public override void Shot()
    {
        if (m_bulletSpeed <= 0f || m_paintDataText == null || string.IsNullOrEmpty(m_paintDataText.text) || m_wayNum <= 0)
        {
            Debug.LogWarning("Cannot shot because BulletSpeed or PaintDataText is not set.");
            return;
        }

        if (m_shooting)
        {
            return;
        }

        if (m_paintData != null)
        {
            for (int i = 0; i < m_paintData.Count; i++)
            {
                m_paintData[i].Clear();
                m_paintData[i] = null;
            }
            m_paintData.Clear();
            m_paintData = null;
        }

        m_paintData = LoadPaintData();
        if (m_paintData == null || m_paintData.Count <= 0)
        {
            Debug.LogWarning("Cannot shot because PaintDataText load error.");
            return;
        }

        m_paintStartAngle = m_paintCenterAngle - (m_paintData[0].Count % 2 == 0 ?
                                                  (m_betweenAngle * m_paintData[0].Count / 2f) + (m_betweenAngle / 2f) :
                                                  m_betweenAngle * Mathf.Floor(m_paintData[0].Count / 2f));

        m_shooting = true;
        m_nowIndex = 0;
        m_delayTimer = 0f;
    }

    protected virtual void Update()
    {
        if (m_shooting == false)
        {
            return;
        }

        if (m_delayTimer >= 0f)
        {
            m_delayTimer -= UbhTimer.instance.deltaTime;
            if (m_delayTimer >= 0f)
            {
                return;
            }
        }

        List<int> lineData = m_paintData[m_nowIndex];
        for (int i = 0; i < lineData.Count; i++)
        {
            if (lineData[i] == 1)
            {
                UbhBullet bullet = GetBullet(transform.position);
                if (bullet == null)
                {
                    break;
                }

                float angle = m_paintStartAngle + (m_betweenAngle * i);

                ShotBullet(bullet, m_bulletSpeed, angle);

                for (int j = 0; j < m_wayNum; j++)
                    {
                        //奇数か偶数かを調べて、
                        float baseAngle = m_wayNum % 2 == 0 ? m_centerAngle - (m_betweenAngle / 2f) : m_centerAngle;
                        //奇数か偶数か精げてWayの角度を決める
                        float m_wayAngle = UbhUtil.GetShiftedAngle(i, baseAngle, m_betweenAngle);

                        ShotBullet(bullet, m_bulletSpeed, m_wayAngle);

                        m_nowIndex++;

                        if (m_nowIndex >= m_bulletNum)
                        {
                            break;
                        }
                    }
            }
        }

        FiredShot();

        m_nowIndex++;
        if (m_nowIndex >= m_paintData.Count)
        {
            FinishedShot();
        }
        else
        {
            m_delayTimer = m_bulletNum;
            if (m_delayTimer <= 0f)
            {
                Update();
            }
        }
    }

    private List<List<int>> LoadPaintData()
    {
        if (m_paintDataText == null || string.IsNullOrEmpty(m_paintDataText.text))
        {
            Debug.LogWarning("Cannot load paint data because PaintDataText file is null or empty.");
            return null;
        }

        string[] lines = m_paintDataText.text.Split(SPLIT_VAL, System.StringSplitOptions.RemoveEmptyEntries);

        var paintData = new List<List<int>>(lines.Length);

        for (int i = 0; i < lines.Length; i++)
        {
            // lines beginning with "#" are ignored as comments.
            if (lines[i].StartsWith("#"))
            {
                continue;
            }
            // add line
            paintData.Add(new List<int>(lines[i].Length));

            for (int j = 0; j < lines[i].Length; j++)
            {
                // bullet is fired into position of "*".
                paintData[paintData.Count - 1].Add(lines[i][j] == '*' ? 1 : 0);
            }
        }

        // reverse because fire from bottom left.
        paintData.Reverse();

        return paintData;
    }
}